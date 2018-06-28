/* The MIT License
 *
 * Copyright (c) 2018 NBCO Yandex.Money LLC
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

/// Managing the underlying `URLSessionTask`.
public class RequestData {

    /// The serial operation queue used to execute all operations after the task completes.
    public let queue: OperationQueue = {
        let operationQueue = OperationQueue()

        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.isSuspended = true
        operationQueue.qualityOfService = .utility

        return operationQueue
    }()

    /// The underlying task.
    public var task: URLSessionTask?

    /// The response received from the server, if any.
    public var response: URLResponse?

    /// The data returned by the server.
    public var data: Data?

    /// The error generated throughout the lifecycle of the task.
    public var error: Error?

    /// The request sent or to be sent to the server.
    public let request: URLRequest

    /// Creates `RequestData` from the `URLRequest`
    ///
    /// - Parameters:
    ///   - request: The request sent or to be sent to the server.
    ///
    /// - Returns: Instance of `RequestData`
    public init(request: URLRequest) {
        self.request = request
    }

    /// Adds a handler to be called once the request has finished.
    ///
    /// - Parameters:
    ///   - completion: The code to be executed once the request has finished.
    public func response(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        queue.addOperation {
            completion(self.data, self.response, self.error)
        }
    }
}
