/* The MIT License
 *
 * Copyright © 2020 NBCO YooMoney LLC
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

/// Provides interface to manage request lifecycle
public class Task<R: ApiResponse> {

    /// Cancel request
    public func cancel() {
        if case .right(let requestData) = requestData {
            requestData.task?.cancel()
        }
    }

    /// Resume request
    public func resume() {
        if case .right(let requestData) = requestData {
            requestData.task?.resume()
        }
    }

    /// Suspend request
    public func suspend() {
        if case .right(let requestData) = requestData {
            requestData.task?.suspend()
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
                         completionHandler: @escaping (URLRequest?,
                                                       HTTPURLResponse?,
                                                       Data?,
                                                       Swift.Error?) -> Void) -> Self {
        switch requestData {
        case .right(let requestData):
            (queue ?? .main).async {
                requestData.response { data, response, error in
                    completionHandler(requestData.request, response as? HTTPURLResponse, data, error)
                }
            }

        case .left(let error):
            (queue ?? .main).async {
                completionHandler(nil, nil, nil, error)
            }
        }

        return self
    }

    /// Adds a handler to be called once the request has finished.
    /// Handler provides result, if performing API Method is successed, else error
    ///
    /// - Parameters:
    ///   - _: Type of API response model
    ///   - queue: The queue on which the completion handler is dispatched. Main queue if nil
    ///   - completion: The code to be executed once the request has finished.
    /// - Returns: Task object
    @discardableResult
    public func responseApi(queue: DispatchQueue? = nil,
                            completion: @escaping (Result<R>) -> Void) -> Self {
        switch requestData {
        case .right(let requestData):
            (queue ?? .main).async {
                requestData.response { data, response, error in
                    let result = R.process(response: response as? HTTPURLResponse, data: data, error: error)
                    completion(result)
                }
            }

        case .left(let error):
            (queue ?? .main).async {
                completion(.left(error))
            }
        }

        return self
    }

    /// Task error
    public enum Error: Swift.Error {
        /// Can't parse response data
        case serializationFailed(text: String)
    }

    let requestData: Result<RequestData>

    init(requestData: Result<RequestData>) {
        self.requestData = requestData
    }
}

// MARK: - LocalizedError

extension Task.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serializationFailed(let text):
            return "Can’t parse response data: " + text
        }
    }
}

private extension Error {
    var isSerializationFailed: Bool {
        let nsError = self as NSError
        return nsError.domain == NSCocoaErrorDomain && nsError.code == NSPropertyListReadCorruptError
    }
}
