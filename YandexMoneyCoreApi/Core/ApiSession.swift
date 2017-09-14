/* The MIT License
 *
 * Copyright (c) 2017 NBCO Yandex.Money LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import Alamofire
import Gloss

/// Provides convenience methods to work with requests.
public class ApiSession {

    /// Private key, used to create signature of JWS
    /// Algorithm EC256
    /// Size: 32 bytes
    public var key: Data? {
        set { jwsEncoding.key = newValue }
        get { return jwsEncoding.key }
    }

    /// Issuer value of JWS header
    public var issuerClaim: IssuerClaim? {
        set { jwsEncoding.issuerClaim = newValue }
        get { return jwsEncoding.issuerClaim }
    }

    /// Overrides all behavior for NSURLSessionTaskDelegate method `URLSession:task:didReceiveChallenge:completionHandler:` and requires the caller to call the `completionHandler`
    public var taskDidReceiveChallengeWithCompletion: ((_ session: URLSession,
        _ task: URLSessionTask,
        _ challenge: URLAuthenticationChallenge,
        _ completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void)? {
        didSet {
            manager.delegate.taskDidReceiveChallengeWithCompletion = taskDidReceiveChallengeWithCompletion
        }
    }

    // MARK: - Private properties
    private let manager: SessionManager
    fileprivate let tokenProvider: OAuthTokenProvider?
    fileprivate let hostProvider: HostProvider
    fileprivate let userAgent: String?
    private let jwsEncoding = JwsEncoding()
    private let urlEncoding = URLEncoding()
    private let jsonEncoding = JSONEncoding()
    private let logger: TaskLogger?

    /// Creates instance of ApiSession class
    ///
    /// - Parameters:
    ///   - tokenProvider: OAuth bearer token provider
    ///   - hostProvider: Host provider for all requests
    ///   - userAgent: User agent header value
    ///   - configuration: Instance of NSURLSessionConfiguration
    ///   - logger: Gloss.Logger for API request-response
    public init(tokenProvider: OAuthTokenProvider? = nil,
                hostProvider: HostProvider,
                userAgent: String? = nil,
                configuration: URLSessionConfiguration? = nil,
                logger: Gloss.Logger? = nil) {
        self.tokenProvider = tokenProvider
        self.hostProvider = hostProvider
        self.userAgent = userAgent
        manager = SessionManager(configuration: configuration ?? .default)
        self.logger = logger.map(TaskLogger.init)
    }

    /// Perfoms API method
    ///
    /// - Parameter apiMethod: Instanse, which conforms protocol ApiMethod
    /// - Returns: Instance of Task class
    public func perform(apiMethod: ApiMethod) -> Task {
        let url: URL
        do {
            url = try self.url(for: apiMethod)
        } catch let error as ApiSession.Error {
            return Task(request: .error(.request(error))).trace(with: logger)
        } catch {
            assertionFailure("Unexpected error: \(error)")
            url = URL(string: "https://yandex.ru")!
        }

        let httpParameters: [String: Any]?
        let encoding: ParameterEncoding
        switch apiMethod.parametersEncoding {

        case .url:
            httpParameters = apiMethod.parameters
            encoding = urlEncoding
        case .json:
            httpParameters = apiMethod.parameters
            encoding = jsonEncoding
        case .jws:
            let jws: String
            do {
                jws = try jwsEncoding.makeJws(parameters: apiMethod.parameters ?? [:])
            } catch let error as JwsEncodingError {
                return Task(request: .error(.request(.jws(error)))).trace(with: logger)
            } catch {
                assertionFailure("Unexpected error: \(error)")
                jws = ""
            }
            httpParameters = ["request": jws]
            encoding = urlEncoding
        }
        return Task(request: .success(manager.request(url,
                                                      method: apiMethod.httpMethod,
                                                      parameters: httpParameters,
                                                      encoding: encoding,
                                                      headers: httpHeaders()))).trace(with: logger)
    }

    /// Cancels all active tasks
    public func cancelAllTasks() {
        manager.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }

    /// API Session errors
    ///
    /// - illegalUrl: Illegal URL
    /// - JWS encoding error
    public enum Error: Swift.Error {
        case illegalUrl(String)
        case jws(JwsEncodingError)
        case host(HostProviderError)
    }
}


// MARK: - Private
private extension ApiSession {
    func url(for apiMethod: ApiMethod) throws -> URL {
        switch try apiMethod.urlInfo(from: hostProvider) {
        case let .url(url):
            return url
        case let .components(host, path):
            return try url(forHost: host, andPath: path)
        }
    }

    private func url(forHost host: String, andPath path: String) throws -> URL {
        guard let components = URLComponents(string: host) else {
            throw Error.illegalUrl(host)
        }
        var resultComponents = components
        if resultComponents.scheme?.isEmpty != false {
            resultComponents.scheme = Constants.defaultScheme
        }
        resultComponents.path = path
        guard let url = resultComponents.url else {
            throw Error.illegalUrl(host + path)
        }
        return url
    }

    func httpHeaders() -> [String: String] {
        let agent = userAgent ?? (Bundle.main.bundleIdentifier ?? "Yandex.Money.SDK") + "/" + osName()
        var headers = ["User-Agent": agent]
        if let token = tokenProvider?.token {
            headers["Authorization"] = "Bearer " + token
        }
        return headers
    }

    private func osName() -> String {
        #if os(iOS)
            return "iOS"
        #elseif os(OSX)
            return "OSX"
        #elseif os(macOS)
            return "macOS"
        #elseif os(tvOS)
            return "tvOS"
        #elseif os(watchOS)
            return "watchOS"
        #elseif os(Linux)
            return "Linux"
        #else
            return ""
        #endif
    }
}


// MARK: - LocalizedError
extension ApiSession.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .illegalUrl(let url): return "Illegal URL '\(url)'"
        case .jws(let error as Swift.Error): return error.localizedDescription
        case .host(let error): return error.localizedDescription
        }
    }
}


// MARK: - API request-response logger
private extension Task {
    @discardableResult func trace(with logger: TaskLogger?) -> Task {
        logger?.trace(task: self)
        return self
    }
}

// MARK: - Constants
private extension ApiSession {
    enum Constants {
        static let defaultScheme = "https"
    }
}
