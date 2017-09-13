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
    /// `host` - "//payment.yamoney.ru", "https://payment.yamoney.ru", "//payment.yamoney.ru:8080"
    /// `path` - "/api/v2/wallets/instance"
    case components(host: String, path: String)
}

/// Common protocol which describes requirements for api method
public protocol ApiMethod {

    /// HTTP method: POST, GET, PUT, etc
    var httpMethod: HTTPMethod { get }

    /// Parameters encoding method
    var parametersEncoding: ParametersEncoding { get }

    /// URL parameters sent with HTTP request
    var parameters: [String: Any]? { get }

    /// Chooses url info
    ///
    /// - Parameter hostsProvider: Hosts provider
    /// - Returns: Url info
    func urlInfo(from hostsProvider: HostsProvider) -> URLInfo
}


// MARK: - Default parameters for methods that confirm Encodable protocol
extension ApiMethod where Self: Gloss.Encodable {
    public var parameters: [String: Any]? {
        return toJSON()
    }
}
