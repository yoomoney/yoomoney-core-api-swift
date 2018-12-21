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

/// Uses `JSONEncoder` to create a JSON representation of the parameters object, which is set as the body of the
/// request. The `Content-Type` HTTP header field of an encoded request is set to `application/json`.
public final class JsonParametersEncoder: ParametersEncoding {

    // MARK: Properties

    /// Returns a `JsonParametersEncoding` instance with default writing options.
    public static var `default`: JsonParametersEncoder { return JsonParametersEncoder() }

    /// Returns a `JsonParametersEncoding` instance with `.prettyPrinted` writing options.
    public static var prettyPrinted: JsonParametersEncoder { return JsonParametersEncoder(options: .prettyPrinted) }

    /// The options for writing the parameters as JSON data.
    public let encoder: JSONEncoder

    /// Date encoding strategy
    public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate

    /// Data encoding strategy
    public var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64

    private var body = Data()

    // MARK: Initialization

    /// Creates a `JsonParametersEncoding` instance using the specified options.
    ///
    /// - Parameters:
    ///   - options: The options for writing the parameters as JSON data.
    ///
    /// - Returns: The new `JSONEncoding` instance.
    public init(options: JSONEncoder.OutputFormatting = []) {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.dataEncodingStrategy = dataEncodingStrategy
        encoder.outputFormatting = options
    }

    // MARK: ParametersEncoding

    /// Encodes the given top-level value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    ///
    /// - throws: `EncodingError.invalidValue` if a non-comforming floating-point value is encountered during encoding,
    ///           and the encoding strategy is `.throw`.
    ///           An error if any value throws an error during encoding.
    public func encode<T>(_ value: T) throws where T: Encodable {
        body = try encoder.encode(value)
    }

    /// Modifies a URL request by encoding parameters and applying them onto an existing request.
    ///
    /// - Parameters:
    ///   - urlRequest: The request to have parameters applied.
    ///
    /// - throws:   An error if any value throws an error during encoding.
    public func passParameters(to urlRequest: inout URLRequest) throws {
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        urlRequest.httpBody = body
    }
}
