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
import XCTest
@testable import YandexMoneyCoreApi

class ApiSessionRequestUrlCommonTests: XCTestCase {

    fileprivate typealias Data = (
        urlInfo: URLInfo,
        expected: String
    )

    private let data: [Data] = [
        (.components(host: "http://ya.ru",  path: ""),        "http://ya.ru"),
        (.components(host: "https://ya.ru", path: ""),        "https://ya.ru"),
        (.components(host: "//ya.ru",       path: ""),        "https://ya.ru"),
        (.components(host: "//ya.ru",       path: "/api"),    "https://ya.ru/api"),
        (.components(host: "//ya.ru",       path: "/api/v1"), "https://ya.ru/api/v1"),

        (.url(URL(string: "https://ya.ru")!),                      "https://ya.ru"),
        (.url(URL(string: "https://ya.ru/api/v1")!),               "https://ya.ru/api/v1"),
        (.url(URL(string: "https://ya.ru/api/v1?p1=123&p2=qwe")!), "https://ya.ru/api/v1?p1=123&p2=qwe")
    ]

    func test() {
        data.forEach(test)
    }
}

private extension ApiSessionRequestUrlCommonTests {

    func test(urlInfo: URLInfo, expected: String) {
        let apiMethod = MockApiMethod(urlInfo: urlInfo)
        XCTAssertEqual(self.url(apiMethod: apiMethod), expected, "Bad url")
    }

    private func url(apiMethod: ApiMethod) -> String? {

        let session = ApiSession()

        let task = session.perform(apiMethod: apiMethod)

        switch task.request {
        case .success(let data):
            return data.request?.url?.absoluteString
        case .error(let error):
            XCTFail("task error: \(error)")
            return nil
        }
    }

}

private class MockApiMethod {

    fileprivate let _urlInfo: URLInfo

    init(urlInfo: URLInfo) {
        _urlInfo = urlInfo
    }
}

extension MockApiMethod: ApiMethod {
    public var httpMethod: HTTPMethod { return .post }
    public var parametersEncoding: ParametersEncoding { return .url }
    public var parameters: [String: Any]? {
        return nil
    }
    public func urlInfo(from _: HostsProvider) -> URLInfo {
        return _urlInfo
    }
}

