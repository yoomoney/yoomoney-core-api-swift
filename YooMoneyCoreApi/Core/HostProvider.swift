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

import protocol Foundation.LocalizedError

/// Error specified for host provider protocol
public enum HostProviderError: Error {

    /// Can't get host for the key
    case unknownKey(String)
}

// MARK: - LocalizedError

extension HostProviderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownKey(let key): return "Unknown host key '\(key)'"
        }
    }
}

/// Common protocol which describes host for API method
public protocol HostProvider {

    /// Host for method key.
    ///
    /// - Parameters:
    ///   - key: Every request can be specified with custom host provider key.
    ///
    /// - Examples: "//host.ru", "https://host.ru", "//host.ru:8080"
    ///
    /// - Note: `https` scheme will be used if not specified
    ///
    /// - Throws: `HostProviderError`
    func host(for key: String) throws -> String
}
