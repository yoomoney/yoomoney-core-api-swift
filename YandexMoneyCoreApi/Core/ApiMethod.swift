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

import enum Alamofire.HTTPMethod
import protocol Gloss.Encodable
import struct Foundation.URL

/// Parameters encoding method
///
/// - url: application/x-www-form-urlencoded
/// - jws: JWS
/// - json: application/json
public enum ParametersEncoding {
    case url
    case jws
    case json
}

/// Url information
public enum URLInfo {

    /// Full url
    case url(URL)

    /// Url components with `host` and `path`
    /// Examples:
    /// `host` - "//host.ru", "https://host.ru", "//host.ru:8080"
    /// `path` - "/api/v1/wallets/instance"
    case components(host: String, path: String)
}

/// Common protocol which describes requirements for api method
public protocol ApiMethod {

    /// Api method response.
    associatedtype Response: ApiResponse

    /// The key of method
    var key: String { get }

    /// HTTP method: POST, GET, PUT, etc
    var httpMethod: HTTPMethod { get }

    /// Parameters encoding method
    var parametersEncoding: ParametersEncoding { get }

    /// URL parameters sent with HTTP request
    var parameters: [String: Any]? { get }

    /// URL headers sent with HTTP request
    var headers: Headers { get }

    /// Chooses url info
    ///
    /// - Parameter hostProvider: Host provider
    /// - Returns: Url info
    /// - Throws: `HostProviderError`
    func urlInfo(from hostProvider: HostProvider) throws -> URLInfo
}

// MARK: - Default parameters for methods that confirm Encodable protocol
extension ApiMethod where Self: Gloss.Encodable {
    public var parameters: [String: Any]? {
        return toJSON()
    }
}

// MARK: - Default headers
extension ApiMethod {
    var headers: Headers {
        return .mempty
    }
}
