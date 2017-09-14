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
import Foundation
import GMEllipticCurveCrypto

/// Encodes JWS
class JwsEncoding {

    var key: Data? {
        set {
            guard let key = newValue, key.count == 256 / 8 else {
                crypto.privateKey = nil
                return
            }
            crypto.privateKey = key
        }
        get {
            return crypto.privateKey
        }
    }

    var issuerClaim: IssuerClaim?

    private let crypto: GMEllipticCurveCrypto = { return GMEllipticCurveCrypto(curve: GMEllipticCurveSecp256r1) }()

    func makeJws(parameters: [String: Any]) throws -> String {
        guard let payload = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            throw JwsEncodingError.illegalParameters(parameters)
        }
        let message = (try header()).base64UrlString() + "." + payload.base64UrlString()
        guard let data = message.data(using: String.Encoding.utf8) else {
            assertionFailure("Message data is nil")
            return ""
        }
        let signature = try sign(data: data)
        return message + "." + signature.base64UrlString()
    }

    private func header() throws -> Data {
        guard let issuerClaim = issuerClaim else { throw JwsEncodingError.issuerClaimNotSet }
        let header: [String: Any] = [
            "alg": "ES256",
            "iat": NSNumber(value: UInt64(Date().timeIntervalSince1970 * 1000)),
            "iss": String(describing: issuerClaim),
            ]
        return try JSONSerialization.data(withJSONObject: header, options: [])
    }

    private func sign(data: Data) throws -> Data {
        guard key != nil else { throw JwsEncodingError.invalidKey }
        return crypto.hashSHA256AndSign(data)
    }
}

/// JWS encoding error
///
/// - illegalParameters: Can't create JWS with requested parameters
/// - invalidKey: Private key not set or does not coform ES256
/// - issuerClaimNotSet: Issuer claim (ISS) not set
public enum JwsEncodingError: Error {
    case illegalParameters([String: Any])
    case invalidKey
    case issuerClaimNotSet
}

// MARK: - LocalizedError
extension JwsEncodingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .illegalParameters(let parameters): return "Can’t create JWS with requested parameters: \(parameters)"
        case .invalidKey: return "Private key not set or does not coform ES256"
        case .issuerClaimNotSet: return "Issuer claim (ISS) not set"
        }
    }
}

private extension Data {
    func base64UrlString() -> String {
        return String(base64EncodedString(options: []).characters.flatMap {
            switch $0 {
            case "/": return "_"
            case "+": return "-"
            case "=": return nil
            default: return $0
            }
        })
    }
}
