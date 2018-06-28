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

/// The response received from the server using `String`
public protocol TextApiResponse: ApiResponse {
    /// Make response from string representation
    ///
    /// - Parameters:
    ///   - text: Response body string representation
    ///
    /// - Returns: Response instance
    init?(text: String)
}

extension TextApiResponse {

    public static func makeResponse(response: HTTPURLResponse, data: Data) -> Self? {
        var encoding: String.Encoding = .utf8

        if let encodingName = response.textEncodingName as CFString! {
            let cfStringEncoding = CFStringConvertIANACharSetNameToEncoding(encodingName)
            let encodingRawValue = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding)
            encoding = String.Encoding(rawValue: encodingRawValue)
        }

        guard let text = String(data: data, encoding: encoding) else {
            return nil
        }
        return self.init(text: text)
    }
}
