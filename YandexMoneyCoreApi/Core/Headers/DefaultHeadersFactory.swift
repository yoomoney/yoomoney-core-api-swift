/*
 * The MIT License (MIT)
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
        let headers = [
            Constants.Key.userAgent: userAgent ?? Constants.Value.userAgent,
        ]
        return Headers(ApiSession.defaultHTTPHeaders.value).mappend(Headers(headers))
    }
}

// MARK: - Constants

private extension DefaultHeadersFactory {
    enum Constants {
        enum Key {
            static let userAgent = "User-Agent"
        }
        enum Value {
            static let userAgent = (Bundle.main.bundleIdentifier ?? "Yandex.Money.SDK") + "/" + osName
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
        }
    }
}
