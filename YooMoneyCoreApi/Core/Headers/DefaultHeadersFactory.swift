/*
 * The MIT License (MIT)
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

import FunctionalSwift

/// Default HTTP headers factory.
public struct DefaultHeadersFactory: HeadersFactory {

    private let userAgent: String?

    /// Creates the default HTTP headers factory.
    ///
    /// - Parameters:
    ///   - userAgent: Name of the user agent.
    ///
    /// - Returns: HTTP headers factory.
    public init(userAgent: String? = nil) {
        self.userAgent = userAgent
    }

    /// Creates HTTP headers.
    ///
    /// - Returns: HTTP default headers.
    public func makeHeaders() -> Headers {
        Headers([
            Constants.Key.userAgent: userAgent ?? Constants.Value.userAgent,
            Constants.Key.acceptEncoding: Constants.Value.acceptEncoding,
            Constants.Key.acceptLanguage: Constants.Value.acceptLanguage,
        ])
    }
}

// MARK: - Constants

private extension DefaultHeadersFactory {
    enum Constants {
        enum Key {
            static let userAgent = "User-Agent"
            static let acceptEncoding = "Accept-Encoding"
            static let acceptLanguage = "Accept-Language"
        }
        enum Value {
            static let userAgent = (Bundle.main.bundleIdentifier ?? "YooMoney.SDK") + "/" + osName
            private static var osName: String {
                #if os(iOS)
                    return "iOS"
                #elseif os(OSX)
                    return "OSX"
                #elseif os(macOS)
                    return "macOS"
                #elseif os(tvOS)
                    return "tvOS"
                #elseif os(watchOS)
                    return "watchOS"
                #elseif os(Linux)
                    return "Linux"
                #else
                    return ""
                #endif
            }
            static let acceptEncoding = "gzip;q=1.0, compress;q=0.5"
            static let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
                let quality = 1.0 - (Double(index) * 0.1)
                return "\(languageCode);q=\(quality)"
            }.joined(separator: ", ")
        }
    }
}
