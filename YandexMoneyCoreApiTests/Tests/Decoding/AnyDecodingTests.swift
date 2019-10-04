/* The MIT License
 *
 * Copyright (c) 2019 NBCO Yandex.Money LLC
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
import FunctionalSwift
import XCTest
@testable import YandexMoneyCoreApi

final class AnyDecodingTests: XCTestCase {

    private struct Mock: Decodable {

        let value: [[String: Any]]?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            let value = try container.decodeIfPresent([Any].self, forKey: .value) as? [[String: Any]]
            self.value = value
        }

        private enum Keys: String, CodingKey {
            case value
        }
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testDecodeIfPresentArrayWithNestedDictionary() {
        let json = """
        {
            "value": [
                {
                    "key-any-1": [
                        {
                            "key-double-1": 0.5
                        },
                        {
                            "key-bool-2": true
                        }
                    ]
                },
                {
                    "key-string-2": "value-string-1"
                },
                {
                    "key-bool-3": false
                },
                {
                    "key-double-4": 2.6
                },
                {
                    "key-int-5": 5
                }
            ]
        }
        """
        // swiftlint:disable force_unwrapping
        let data = json.data(using: .utf8)!
        // swiftlint:enable force_unwrapping
        // swiftlint:disable:next force_try
        let object = try! JSONDecoder().decode(Mock.self, from: data)
        let value = object.value
        XCTAssertEqual(value?.count, 5)
        XCTAssertEqual((value?[0]["key-any-1"] as? [[String: Any]])?.count, 2)
        XCTAssertEqual((value?[0]["key-any-1"] as? [[String: Any]])?[0]["key-double-1"] as? Double, 0.5)
        XCTAssertEqual((value?[0]["key-any-1"] as? [[String: Any]])?[1]["key-bool-2"] as? Bool, true)
        XCTAssertEqual(value?[1]["key-string-2"] as? String, "value-string-1")
        XCTAssertEqual(value?[2]["key-bool-3"] as? Bool, false)
        XCTAssertEqual(value?[3]["key-double-4"] as? Double, 2.6)
        XCTAssertEqual(value?[4]["key-int-5"] as? Int, 5)
    }
}
