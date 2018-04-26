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
import FunctionalSwift
import protocol Gloss.Logger

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

    /// Overrides all behavior for NSURLSessionTaskDelegate method
    /// `URLSession:task:didReceiveChallenge:completionHandler:` and requires the caller to call the `completionHandler`
    public var taskDidReceiveChallengeWithCompletion: ((_ session: URLSession,
                                                        _ challenge: URLAuthenticationChallenge,
                                                        _ completionHandler: (URLSession.AuthChallengeDisposition,
                                                                              URLCredential?) -> Void) -> Void)? {
        didSet {
            delegate.taskDidReceiveChallengeWithCompletion = taskDidReceiveChallengeWithCompletion
        }
    }

    // MARK: - Private properties

    private let session: URLSession
    private let delegate: ApiSessionDelegate
    private let hostProvider: HostProvider
    private let logger: TaskLogger?

    private let jwsEncoding = JwsEncoding()
    private let jsonEncoding = JSONEncoding()

    /// Creates instance of ApiSession class
    ///
    /// - Parameters:
    ///   - hostProvider: Host provider for all requests
    ///   - configuration: Instance of URLSessionConfiguration
    ///   - logger: Gloss.Logger for API request-response
    public init(hostProvider: HostProvider,
                configuration: URLSessionConfiguration = .default,
                logger: Gloss.Logger? = nil) {
        self.hostProvider = hostProvider

        self.logger = logger.map(TaskLogger.init)
        self.delegate = ApiSessionDelegate()
        self.session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }

    deinit {
        session.invalidateAndCancel()
    }

    /// Performs API method
    ///
    /// - Parameter apiMethod: Instance, which conforms protocol ApiMethod
    /// - Returns: Instance of Task class
    public func perform<M: ApiMethod>(apiMethod: M) -> Task<M.Response> {
        let url: URL
        do {
            url = try self.url(for: apiMethod)
        } catch let error as ApiSession.ErrorApiSession {
            return Task(requestData: .left(error)).trace(with: logger)
        } catch {
            assertionFailure("Unexpected error: \(error)")
            // swiftlint:disable:next force_unwrapping
            url = URL(string: "https://yandex.ru")!
        }

        let httpParameters: [String: Any]?
        let encoding: ParameterEncoding
        switch apiMethod.parametersEncoding {

        case .url(let arrayEncoding):
            httpParameters = apiMethod.parameters
            encoding = URLEncoding(arrayEncoding: arrayEncoding)
        case .json:
            httpParameters = apiMethod.parameters
            encoding = jsonEncoding
        case .jws:
            let jws: String
            do {
                jws = try jwsEncoding.makeJws(parameters: apiMethod.parameters ?? [:])
            } catch let error as JwsEncodingError {
                return Task(requestData: .left(ErrorApiSession.jws(error))).trace(with: logger)
            } catch {
                assertionFailure("Unexpected error: \(error)")
                jws = ""
            }
            httpParameters = ["request": jws]
            encoding = URLEncoding(arrayEncoding: .brackets)
        }

        do {
            let request = URLRequest(url: url, method: apiMethod.httpMethod, headers: apiMethod.headers)
            let encodedRequest = try encoding.encode(request, with: httpParameters)
            let requestData = RequestData(session: session, request: encodedRequest)
            return Task(requestData: .right(requestData)).trace(with: logger)
        } catch {
            return Task(requestData: .left(error)).trace(with: logger)
        }
    }

    /// Cancels all active tasks
    @available(iOS 9.0, *)
    public func cancelAllTasks() {
        session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }

    /// API Session errors
    ///
    /// - illegalUrl: Illegal URL
    /// - JWS encoding error
    /// - host: host provider error
    public enum ErrorApiSession: Error {
        case illegalUrl(String)
        case jws(JwsEncodingError)
        case host(HostProviderError)
    }

    public static let defaultHTTPHeaders: Headers = {
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"

        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
        }.joined(separator: ", ")

        // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
        // Example: `iOS Example/1.0 (org.alamofire.iOS-Example; build:1; iOS 10.0.0) Alamofire/4.0.0`
        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
                let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
                let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"

                let osNameVersion: String = {
                    let version = ProcessInfo.processInfo.operatingSystemVersion
                    let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

                    let osName: String = {
                        #if os(iOS)
                            return "iOS"
                        #elseif os(watchOS)
                            return "watchOS"
                        #elseif os(tvOS)
                            return "tvOS"
                        #elseif os(macOS)
                            return "OS X"
                        #elseif os(Linux)
                            return "Linux"
                        #else
                            return "Unknown"
                        #endif
                    }()

                    return "\(osName) \(versionString)"
                }()

                return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"
            }

            return "CoreApi"
        }()

        let value = [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent": userAgent,
        ]
        let headers = Headers(value)
        return headers
    }()
}

// MARK: - Private

private extension ApiSession {
    func url<M: ApiMethod>(for apiMethod: M) throws -> URL {
        switch try apiMethod.urlInfo(from: hostProvider) {
        case let .url(url):
            return url
        case let .components(host, path):
            return try url(forHost: host, andPath: path)
        }
    }

    private func url(forHost host: String, andPath path: String) throws -> URL {
        guard let components = URLComponents(string: host) else {
            throw ErrorApiSession.illegalUrl(host)
        }
        var resultComponents = components
        if resultComponents.scheme?.isEmpty != false {
            resultComponents.scheme = Constants.defaultScheme
        }
        resultComponents.path = path
        guard let url = resultComponents.url else {
            throw ErrorApiSession.illegalUrl(host + path)
        }
        return url
    }
}

// MARK: - LocalizedError

extension ApiSession.ErrorApiSession: LocalizedError {
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
