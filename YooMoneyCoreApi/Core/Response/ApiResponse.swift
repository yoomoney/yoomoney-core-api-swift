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
import typealias FunctionalSwift.Result

/// The response from the server.
public protocol ApiResponse {

    /// Date decoding strategy
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }

    /// Data decoding strategy
    static var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy { get }

    /// Creates response.
    ///
    /// - Parameters:
    ///   - response: object represents a response to an HTTP URL load.
    ///   - data: response data
    ///
    /// - Returns: The `Type` which implement protocol.
    static func makeResponse(response: HTTPURLResponse, data: Data) -> Self?

    /// Serialization process.
    ///
    /// - Parameters:
    ///   - response: object represents a response to an HTTP URL load.
    ///   - data: response data
    ///   - error: response error
    ///
    /// - Returns: Result representation of `Ether` type where `left` value is `Error` and `right` value is success.
    static func process(response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<Self>

    /// Creates specific error.
    ///
    /// - Parameters:
    ///   - response: object represents a response to an HTTP URL load.
    ///   - data: response data
    ///
    /// - Returns: Error
    static func makeSpecificError(response: HTTPURLResponse, data: Data) -> Error?
}

extension ApiResponse {

    public static func makeSpecificError(response: HTTPURLResponse, data: Data) -> Error? {
        return nil
    }

    public static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        return .deferredToDate
    }
    public static var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy {
        return .base64
    }
}
