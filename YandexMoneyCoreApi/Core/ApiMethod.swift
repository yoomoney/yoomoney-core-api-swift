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

/// HTTP method definitions.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
public enum HTTPMethod: String {
    /// HTTP method options
    case options = "OPTIONS"
    /// HTTP method get
    case get = "GET"
    /// HTTP method head
    case head = "HEAD"
    /// HTTP method post
    case post = "POST"
    /// HTTP method put
    case put = "PUT"
    /// HTTP method patch
    case patch = "PATCH"
    /// HTTP method delete
    case delete = "DELETE"
    /// HTTP method trace
    case trace = "TRACE"
    /// HTTP method connect
    case connect = "CONNECT"
}

/// A type used to define how a set of parameters are applied to a `URLRequest`.
public protocol ParametersEncoding {

    // TODO: Use Encoder protocol

    /// Date encoding strategy
    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get set }

    /// Data encoding strategy
    var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy { get set }

    /// Encodes the given top-level value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    ///
    /// - throws: `EncodingError.invalidValue` if a non-comforming floating-point value is encountered during encoding,
    ///           and the encoding strategy is `.throw`.
    ///           An error if any value throws an error during encoding.
    func encode<T>(_ value: T) throws where T: Encodable

    /// Modify a URL request by encoding parameters and applying them onto an existing request.
    ///
    /// - Parameters:
    ///   - urlRequest: The request to have parameters applied.
    ///
    /// - throws:   An error if any value throws an error during encoding.
    func passParameters(to urlRequest: inout URLRequest) throws
}

/// URL information.
public enum URLInfo {

    /// Full URL.
    case url(URL)

    /// URL components with `host` and `path`.
    ///
    /// - Parameters:
    ///   - host: URL host.
    ///   - path: URL path.
    ///
    /// - Examples:
    ///   - `host`: "//host.ru", "https://host.ru", "//host.ru:8080"
    ///   - `path`: "/api/v1/wallets/instance"
    case components(host: String, path: String)
}

/// Common protocol which describes requirements for api method
public protocol ApiMethod: Encodable {

    /// Api method response.
    associatedtype Response: ApiResponse

    /// Host provider key.
    var hostProviderKey: String { get }

    /// HTTP method: POST, GET, PUT, etc
    var httpMethod: HTTPMethod { get }

    /// Parameters encoding method.
    var parametersEncoding: ParametersEncoding { get }

    /// URL headers sent with HTTP request.
    var headers: Headers { get }

    /// Chooses URL info.
    ///
    /// - Parameters:
    ///   - hostProvider: Host provider
    ///
    /// - Returns: URL info
    ///
    /// - Throws: `HostProviderError`
    func urlInfo(from hostProvider: HostProvider) throws -> URLInfo
}

// MARK: - Default headers

extension ApiMethod {
    /// URL headers sent with HTTP request.
    public var headers: Headers {
        return .mempty
    }
}
