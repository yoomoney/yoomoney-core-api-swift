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

import Alamofire
import Foundation
import Gloss

/// Provides interface to manage request lifecycle
public class Task {

    /// Cancel request
    public func cancel() {
        if case .success(let request) = request {
            request.cancel()
        }
    }

    /// Resume request
    public func resume() {
        if case .success(let request) = request {
            request.resume()
        }
    }

    /// Suspend request
    public func suspend() {
        if case .success(let request) = request {
            request.suspend()
        }
    }

    /// Adds a handler to be called once the request has finished.
    ///
    /// - Parameters:
    ///   - queue: The queue on which the completion handler is dispatched.
    ///   - completionHandler: The code to be executed once the request has finished.
    /// - Returns: Task object
    @discardableResult
    public func response(queue: DispatchQueue? = nil,
                         completionHandler: @escaping (URLRequest?, HTTPURLResponse?, Data?, Swift.Error?) -> Void)
        -> Self {
        switch request {
        case .success(let request):
            request.response(queue: queue) { dataResponse in
                completionHandler(dataResponse.request, dataResponse.response, dataResponse.data, dataResponse.error)
            }

        case .error(let error):
            (queue ?? .main).async {
                completionHandler(nil, nil, nil, error)
            }
        }
        return self
    }

    let request: Result<DataRequest, Error>

    init(request: Result<DataRequest, Error>) {
        self.request = request
    }

    /// Adds a handler to be called once the request has finished.
    /// Handler provides result, if performing API Method is successed, else error
    ///
    /// - Parameters:
    ///   - _: Type of API response model
    ///   - queue: The queue on which the completion handler is dispatched. Main queue if nil
    ///   - completion: The code to be executed once the request has finished.
    /// - Returns: The Task
    @discardableResult
    public func responseApi<ResponseType: Gloss.Decodable>(
        _: ResponseType.Type,
        queue: DispatchQueue? = nil,
        completion: @escaping (Result<ResponseType, Error>) -> Void) -> Self {

        switch request {
        case .success(let dataRequest):
            dataRequest.responseJSON(queue: queue) { dataResponse in
                self.processJsonResponse(dataResponse: dataResponse, completion: completion)
            }

        case .error(let error):
            (queue ?? .main).async {
                completion(.error(error))
            }
        }
        return self
    }

    /// Task error
    ///
    /// - serializationFailed: Can't parse response data
    /// - api: API returned error
    /// - response: Network error
    /// - request: Error in request forming
    /// - responseSpecific: Response specific error
    public enum Error: Swift.Error {
        case serializationFailed(text: String)
        case api(ApiResponseError)
        case response(Swift.Error)
        case request(ApiSession.Error)
        case responseSpecific(Swift.Error)
    }
}

// MARK: - Private
private extension Task {
    func processJsonResponse<ResponseType: Gloss.Decodable>(
        dataResponse: DataResponse<Any>,
        completion: @escaping (Result<ResponseType, Error>) -> Void) {

        var result: Result<ResponseType, Task.Error>
        defer {
            completion(result)
        }
        guard dataResponse.response?.statusCode != 500 else {
            result = .error(.api(.technicalError(nextRetry: .milliseconds(5000))))

            // TODO: Remove when stop receiving TechnicalError + Refused
            if case .success(let json) = dataResponse.result,
                ((json as? [String: Any])?["status"] as? String) == "Refused" {
                result = .error(.api(.unknown("\(json)")))
            }
            // ..... . .. . .  ..  . .. . . .   .   .       .        .             .                        .

            return
        }

        guard dataResponse.response?.statusCode != 401 else {
            result = .error(.api(.invalidToken))
            return
        }

        switch dataResponse.result {
        case .success(let json as JSON):

            if let error = (ResponseType.self as? ResponseWithCustomError.Type)?.error(from: json) {
                result = .error(.responseSpecific(error))
            } else if let response = ResponseType(json: json) {
                result = .success(response)
            } else {
                result = .error(.api(ApiResponseError(json: json) ?? .unknown("\(json)")))
            }

        case .success(let value):
            result = .error(.serializationFailed(text: "\(value)"))

        case .failure(let error):
            if error.isSerializationFailed {
                var string: String?
                if let data = dataResponse.data {
                    string = String(data: data, encoding: .utf8)
                }
                result = .error(.serializationFailed(text: string ?? ""))
            } else {
                result = .error(.response(error))
            }
        }
    }
}

// MARK: - LocalizedError
extension Task.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serializationFailed(text: let text):
            return "Can’t parse response data: " + text

        case .api(let error as Swift.Error),
             .response(let error),
             .request(let error as Swift.Error),
             .responseSpecific(let error):
            return error.localizedDescription
        }
    }
}

private extension Error {
    var isSerializationFailed: Bool {
        let nsError = self as NSError
        return nsError.domain == NSCocoaErrorDomain && nsError.code == NSPropertyListReadCorruptError
    }
}
