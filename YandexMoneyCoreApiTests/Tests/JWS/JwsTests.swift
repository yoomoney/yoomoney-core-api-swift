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

import Alamofire
import Gloss
import GMEllipticCurveCrypto
import XCTest
@testable import YandexMoneyCoreApi

/// JWS Tests
class JwsTests: XCTestCase {

    struct Jws {
        static let privateKey = "dpq3b8ki_YkBOQK2UPAfzL0MF829OTw4_Boy5SlfliI".dataFromBase64()
        static let publicKey =
            "BGc2eJhI4rJskujJtazNCCL2VxHYJUOjk0sZPWKkNQQgqMRzebXyCrukf5U8Qua1gTyT7OeZ7nMhBedyscPM0v8".dataFromBase64()

        static let encoding: JwsEncoding = {
            let jwsEncoding = JwsEncoding()
            jwsEncoding.issuerClaim = IssuerClaim.instanceId("000")
            jwsEncoding.key = privateKey as Data?
            return jwsEncoding
        }()

        static let payload: [String: Any] = ["param1": "value1", "param2": ["param21": "value21"]]
    }

    func testJwsGenerate() {
        var jws: String?
        measure {
            XCTCatch {
                jws = try self.generateJws()
            }
        }
        XCTAssertNotNil(jwsParts(jws), "Bad JWS")
    }

    func testJwsPayload() {
        guard let jwsParts = jwsParts(try? generateJws()) else { return }
        guard let data = jwsParts[1].dataFromBase64() else {
            XCTFail("Payload data is not JSON")
            return
        }
        guard let payload =
            (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
                XCTFail("Payload is not JSON")
                return
        }
        XCTAssertEqual(Jws.payload, payload, "Payload broken")
    }

    func testJwsSignature() {
        guard let jwsParts = jwsParts(try? generateJws()) else { return }

        let crypto = GMEllipticCurveCrypto(curve: GMEllipticCurveSecp256r1)
        crypto?.publicKey = Jws.publicKey as Data!

        guard let data = jwsParts[2].dataFromBase64() else {
            XCTFail("Signature data not valid")
            return
        }
        guard let hash = crypto?.hashSHA256AndVerifySignature(
            data,
            for: (jwsParts[0] + "." + jwsParts[1]).data(using: .utf8)) else {
                XCTFail("Signature not valid")
                return
        }
        XCTAssert(hash, "Signature not valid")
    }

    fileprivate func generateJws() throws -> String {
        return try Jws.encoding.makeJws(parameters: Jws.payload)
    }

    fileprivate func jwsParts(_ jws: String?) -> [String]? {
        if let jwsParts = jws?.split(separator: ".").map(String.init), jwsParts.count == 3 {
            return jwsParts
        } else {
            return nil
        }
    }

}
