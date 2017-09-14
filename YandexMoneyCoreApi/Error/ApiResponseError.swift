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
import Gloss

///
/// API response Error
///
/// Errors for HTTP status 200 (OK). Request accepted and successfuly proceded
///
/// - orderRefused: Refused by merchant or no payment method available
/// - authorizationRejected: Payment authorization rejected
/// - alreadyAuthorized: Order already authorized
/// - inappropriateStatus: Operation not alowed for order with current status
/// - orderExpired: Trying to pay expired order
/// - identificationRequired: User identification required. Order finally rejected
/// - recipientAccountClosed: Recipient account closed
/// - insufficientFunds: Not enough funds for this order
/// - operationNotSupported: Operation not supported for this order
/// - partialRefundNotAllowed: Partial refund not allowed for this order type
/// - illegalParameters: Merchant rejected parameters
/// - payerNotFound: Payer account not found in merchant's regester
///
/// Errors for HTTP status 202 (Accepted). Request accepted but final state unknown yet
///
/// - requestStateUnknown: Request state unknown and should be repeated to get final state
///
/// Errors for HTTP status 400 (Bad Request). Request rejected
///
/// - syntaxError: HTTP request or JWS parsing failed
/// - illegalHeader: JWS header missing or holds illegal values
/// - illegalParameter: JWS payload missing or holds illegal values
/// - intervalTooLarge: Too large selection interval requested
/// - orderDuplication: Tryng to create different order with previously user order ID
/// - amountRemainderTooLow: Not allowed partial refund amount. 
///                          Partial amount should be reduced or total amount refunded
///
/// Errors for HTTP status 401 (Unauthorized). Authentication or authorization error. Request rejected
///
/// - invalidToken: OAuth2 wallet authorization invalid
/// - illegalSignature: Illegal JWS signature
///
/// Errors for HTTP status 403 (Forbidden). Operation not allowed for user. Request rejected
///
/// - sourceNotAllowed: Source not allowed for this order now
/// - methodNotAllowed: Method not allowed for this order
/// - recipientNotAllowed: Transfers to payee not allowed, merchant disabled or blocked
/// - instrumentNotAllowed: Order not allowed to be paid by this instrument
/// - operationForbidden: Requested operation forbidden for this order
/// - invalidScope: OAuth2 authorization scope not enough for requested operation
/// - parameterNotAllowed: Parameter value not allowed
///
/// Error for HTTP status 500 (Internal Server Error). 
/// Technical Error. Request accepted or rejected, and should be repeated to get final status
///
/// - technicalError: Technical Error. Request accepted or rejected, and should be repeated to get final status
///
/// OAuth2 API specifed errors
///
/// - phoneNumberRefused: Phone number not allowed for Yandex.Wallet registration
/// - applicationBlocked: Instance ID or Client ID not allowed for Yandex.Wallet registration
/// - alreadyExists: Yandex.Wallet for current account arleady exists
/// - linkedPhoneRequired: No phone linked for this account
/// - limitExceeded: Phone number validation retries limit temporary exceeded
///
public enum ApiResponseError: Error {
    // MARK: Status 200
    case orderRefused
    case authorizationRejected
    case alreadyAuthorized
    case inappropriateStatus(status: String)
    case orderExpired
    case identificationRequired
    case accountAlreadyIdentified
    case personificationRefused
    case recipientAccountClosed
    case insufficientFunds
    case operationNotSupported
    case partialRefundNotAllowed
    case illegalParameters
    case payerNotFound

    // MARK: Status 202
    case requestStateUnknown(nextRetry: DispatchTimeInterval)

    // MARK: Status 400
    case syntaxError
    case illegalHeader(parameterName: String)
    case illegalParameter(parameterName: String)
    case intervalTooLarge(parameterName: String)
    case orderDuplication
    case amountRemainderTooLow

    // MARK: Status 401
    case invalidToken
    case illegalSignature

    // MARK: Status 403
    case sourceNotAllowed
    case methodNotAllowed
    case recipientNotAllowed
    case instrumentNotAllowed
    case operationForbidden
    case invalidScope
    case parameterNotAllowed(parameterName: String)

    // MARK: Status 500
    case technicalError(nextRetry: DispatchTimeInterval)

    // MARK: OAuth2 API
    case phoneNumberRefused
    case applicationBlocked
    case alreadyExists
    case linkedPhoneRequired
    case limitExceeded

    // MARK: APIv1 Payments
    case accountBlocked(uri: String)
    case extActionRequired(uri: String)

    // MARK: Undefined
    case unknown(String)
}

// MARK: - Decodable
extension ApiResponseError: Gloss.Decodable {
    // swiftlint:disable:next cyclomatic_complexity
    public init?(json: JSON) {
        guard let error = json[Json.Keys.error.rawValue] as? String else { return nil }

        switch error {
        // MARK: Status 200
        case Json.Values.OrderRefused.rawValue: self = .orderRefused
        case Json.Values.AuthorizationRejected.rawValue: self = .authorizationRejected
        case Json.Values.AlreadyAuthorized.rawValue: self = .alreadyAuthorized
        case Json.Values.InappropriateStatus.rawValue:
            self = .inappropriateStatus(status: json[Json.Keys.status.rawValue] as? String ?? "")
        case Json.Values.OrderExpired.rawValue: self = .orderExpired
        case Json.Values.IdentificationRequired.rawValue: self = .identificationRequired
        case Json.Values.RecipientAccountClosed.rawValue: self = .recipientAccountClosed
        case Json.Values.InsufficientFunds.rawValue: self = .insufficientFunds
        case Json.Values.OperationNotSupported.rawValue: self = .operationNotSupported
        case Json.Values.PartialRefundNotAllowed.rawValue: self = .partialRefundNotAllowed
        case Json.Values.IllegalParameters.rawValue, Json.OAuth2.illegalParams.rawValue: self = .illegalParameters
        case Json.Values.PayerNotFound.rawValue: self = .payerNotFound

        // MARK: Status 202
        case Json.Values.RequestStateUnknown.rawValue:
            self = .requestStateUnknown(nextRetry: .milliseconds(json[Json.Keys.nextRetry.rawValue] as? Int ?? 5000))

        // MARK: Status 400
        case Json.Values.SyntaxError.rawValue: self = .syntaxError
        case Json.Values.IllegalHeader.rawValue:
            self = .illegalHeader(parameterName: json[Json.Keys.parameterName.rawValue] as? String ?? "")
        case Json.Values.IllegalParameter.rawValue:
            self = .illegalParameter(parameterName: json[Json.Keys.parameterName.rawValue] as? String ?? "")
        case Json.Values.IntervalTooLarge.rawValue:
            self = .intervalTooLarge(parameterName: json[Json.Keys.parameterName.rawValue] as? String ?? "")
        case Json.Values.OrderDuplication.rawValue:
            self = .orderDuplication
        case Json.Values.AmountRemainderTooLow.rawValue: self = .amountRemainderTooLow

        // MARK: Status 401
        case Json.Values.InvalidToken.rawValue: self = .invalidToken
        case Json.Values.IllegalSignature.rawValue: self = .illegalSignature

        // MARK: Status 403
        case Json.Values.SourceNotAllowed.rawValue: self = .sourceNotAllowed
        case Json.Values.MethodNotAllowed.rawValue: self = .methodNotAllowed
        case Json.Values.RecipientNotAllowed.rawValue: self = .recipientNotAllowed
        case Json.Values.InstrumentNotAllowed.rawValue: self = .instrumentNotAllowed
        case Json.Values.OperationForbidden.rawValue: self = .operationForbidden
        case Json.Values.InvalidScope.rawValue: self = .invalidScope
        case Json.Values.ParameterNotAllowed.rawValue:
            self = .parameterNotAllowed(parameterName: json[Json.Keys.parameterName.rawValue] as? String ?? "")

        // MARK: Status 500
        case Json.Values.TechnicalError.rawValue, Json.OAuth2.technicalError.rawValue:
            self = .technicalError(nextRetry: .milliseconds(json[Json.Keys.nextRetry.rawValue] as? Int ?? 5000))

        // MARK: OAuth2 API
        case Json.OAuth2.illegalParamOauthToken.rawValue: self = .illegalParameter(parameterName: "oauthToken")
        case Json.OAuth2.illegalParamRequestId.rawValue: self = .illegalParameter(parameterName: "requestId")
        case Json.OAuth2.illegalParamPhoneNumber.rawValue: self = .illegalParameter(parameterName: "phoneNumber")
        case Json.OAuth2.illegalParamActivationCode.rawValue: self = .illegalParameter(parameterName: "activationCode")
        case Json.OAuth2.illegalParamInstanceId.rawValue: self = .illegalParameter(parameterName: "instanceId")
        case Json.OAuth2.illegalParamDeviceId.rawValue: self = .illegalParameter(parameterName: "deviceId")
        case Json.OAuth2.illegalParamLatitude.rawValue: self = .illegalParameter(parameterName: "latitude")
        case Json.OAuth2.illegalParamLongitude.rawValue: self = .illegalParameter(parameterName: "longitude")
        case Json.OAuth2.phoneNumberRefused.rawValue: self = .phoneNumberRefused
        case Json.OAuth2.applicationBlocked.rawValue: self = .applicationBlocked
        case Json.OAuth2.alreadyExists.rawValue: self = .alreadyExists
        case Json.OAuth2.linkedPhoneRequired.rawValue: self = .linkedPhoneRequired
        case Json.OAuth2.limitExceeded.rawValue: self = .limitExceeded

        // MARK: History API
        case Json.History.illegalParamTill.rawValue: self = .illegalParameter(parameterName: "till")
        case Json.History.illegalParamFrom.rawValue: self = .illegalParameter(parameterName: "from")
        case Json.History.illegalParamType.rawValue: self = .illegalParameter(parameterName: "type")
        case Json.History.illegalParamLabel.rawValue: self = .illegalParameter(parameterName: "label")
        case Json.History.illegalParamRecords.rawValue: self = .illegalParameter(parameterName: "records")
        case Json.History.illegalParamOperationId.rawValue: self = .illegalParameter(parameterName: "operation_id")
        case Json.History.illegalParamFavoriteId.rawValue: self = .illegalParameter(parameterName: "favorite_id")
        case Json.History.illegalParamFavoriteIndex.rawValue: self = .illegalParameter(parameterName: "index")
        case Json.History.illegalParamStartRecord.rawValue: self = .illegalParameter(parameterName: "start_record")

        // MARK: API v1 payments
        case Json.ApiV1Payments.illegalParamLabel.rawValue: self = .illegalParameter(parameterName: "label")
        case Json.ApiV1Payments.illegalParamTo.rawValue: self = .illegalParameter(parameterName: "to")
        case Json.ApiV1Payments.illegalParamAmount.rawValue: self = .illegalParameter(parameterName: "amount")
        case Json.ApiV1Payments.illegalParamAmountDue.rawValue: self = .illegalParameter(parameterName: "amount_due")
        case Json.ApiV1Payments.illegalParamComment.rawValue: self = .illegalParameter(parameterName: "comment")
        case Json.ApiV1Payments.illegalParamMessage.rawValue: self = .illegalParameter(parameterName: "message")
        case Json.ApiV1Payments.illegalParamExpirePeriod.rawValue:
            self = .illegalParameter(parameterName: "expire_period")
        case Json.ApiV1Payments.notEnoughFunds.rawValue: self = .insufficientFunds
        case Json.ApiV1Payments.paymentRefused.rawValue: self = .orderRefused
        case Json.ApiV1Payments.payeeNotFound.rawValue: self = .recipientAccountClosed
        case Json.ApiV1Payments.authorizationReject.rawValue: self = .authorizationRejected
        case Json.ApiV1Payments.accountBlocked.rawValue:
            self = .accountBlocked(uri: json[Json.Keys.accountUnblockUri.rawValue] as? String ?? "")
        case Json.ApiV1Payments.extActionRequired.rawValue:
            self = .extActionRequired(uri: json[Json.Keys.extActionUri.rawValue] as? String ?? "")
        case Json.ApiV1Payments.contractNotFound.rawValue: self = .illegalParameter(parameterName: "orderId")
        case Json.ApiV1Payments.moneySourceNotAvailable.rawValue: self = .sourceNotAllowed
        case Json.ApiV1Payments.illegalParamCsc.rawValue: self = .illegalParameter(parameterName: "csc")
        case Json.ApiV1Payments.accountClosed.rawValue: self = .recipientAccountClosed
        case Json.ApiV1Payments.illegalParamExtAuthSuccessUri.rawValue:
            self = .illegalParameter(parameterName: "extAuthSuccessUri")
        case Json.ApiV1Payments.illegalParamExtAuthFailUri.rawValue:
            self = .illegalParameter(parameterName: "extAuthFailUri")
        case Json.ApiV1Payments.illegalParamRequestId.rawValue: self = .illegalParameter(parameterName: "requestId")
        case Json.ApiV1Payments.illegalParamMoneySourceToken.rawValue:
            self = .illegalParameter(parameterName: "moneySourceToken")
        case Json.ApiV1Payments.illegalParamClientId.rawValue: self = .illegalParameter(parameterName: "clientId")

        // MARK: - Search
        case Json.Search.illegalParamQuery.rawValue: self = .illegalParameter(parameterName: "query")
        case Json.Search.illegalParamRecordsLimit.rawValue: self = .illegalParameter(parameterName: "records")
        case Json.Search.illegalParamOperationType.rawValue: self = .illegalParameter(parameterName: "type")

        case Json.Personification.accountAlreadyIdentified.rawValue: self = .accountAlreadyIdentified
        case Json.Personification.personificationRefused.rawValue: self = .personificationRefused
        // MARK: Undefined
        default: self = .unknown(error)
        }
    }

    private enum Json {
        enum Keys: String {
            case json
            case error
            case nextRetry
            case status
            case parameterName
            case parameterText

            // MARK: API v1 payments
            case accountUnblockUri = "account_unblock_uri"
            case extActionUri = "ext_action_uri"
        }

        enum Values: String {
            // MARK: Status 200
            case OrderRefused
            case AuthorizationRejected
            case AlreadyAuthorized
            case InappropriateStatus
            case OrderExpired
            case IdentificationRequired
            case RecipientAccountClosed
            case InsufficientFunds
            case OperationNotSupported
            case PartialRefundNotAllowed
            case IllegalParameters
            case PayerNotFound

            // MARK: Status 202
            case RequestStateUnknown

            // MARK: Status 400
            case SyntaxError
            case IllegalHeader
            case IllegalParameter
            case IntervalTooLarge
            case OrderDuplication
            case AmountRemainderTooLow

            // MARK: Status 401
            case InvalidToken = "invalid_token"
            case IllegalSignature

            // MARK: Status 403
            case SourceNotAllowed
            case MethodNotAllowed
            case RecipientNotAllowed
            case InstrumentNotAllowed
            case OperationForbidden
            case InvalidScope
            case ParameterNotAllowed

            // MARK: Status 500
            case TechnicalError
        }

        enum OAuth2: String {
            case technicalError = "technical_error"
            case phoneNumberRefused = "phone_number_refused"
            case applicationBlocked = "application_blocked"
            case alreadyExists = "already_exists"
            case linkedPhoneRequired = "linked_phone_required"
            case limitExceeded = "limit_exceeded"
            case illegalParams = "illegal_params"
            case illegalParamOauthToken = "illegal_param_oauth_token"
            case illegalParamRequestId = "illegal_param_request_id"
            case illegalParamPhoneNumber = "illegal_param_phone_number"
            case illegalParamActivationCode = "illegal_param_activation_code"
            case illegalParamInstanceId = "illegal_param_instance_id"
            case illegalParamDeviceId = "illegal_param_device_id"
            case illegalParamLatitude = "illegal_param_latitude"
            case illegalParamLongitude = "illegal_param_longitude"
        }

        enum History: String {
            case illegalParamType = "illegal_param_type"
            case illegalParamLabel = "illegal_param_label"
            case illegalParamStartRecord = "illegal_param_start_record"
            case illegalParamRecords = "illegal_param_records"
            case illegalParamFrom = "illegal_param_from"
            case illegalParamTill = "illegal_param_till"
            case illegalParamOperationId = "illegal_param_operation_id"
            case illegalParamFavoriteId = "illegal_param_favorite_id"
            case illegalParamFavoriteIndex = "illegal_param_index"
        }

        enum ApiV1Payments: String {
            case illegalParamLabel = "illegal_param_label"
            case illegalParamTo = "illegal_param_to"
            case illegalParamAmount = "illegal_param_amount"
            case illegalParamAmountDue = "illegal_param_amount_due"
            case illegalParamComment = "illegal_param_comment"
            case illegalParamMessage = "illegal_param_message"
            case illegalParamExpirePeriod = "illegal_param_expire_period"
            case notEnoughFunds = "not_enough_funds"
            case paymentRefused = "payment_refused"
            case payeeNotFound = "payee_not_found"
            case authorizationReject = "authorization_reject"
            case accountBlocked = "account_blocked"
            case extActionRequired = "ext_action_required"
            case contractNotFound = "contract_not_found"
            case moneySourceNotAvailable = "money_source_not_available"
            case illegalParamCsc = "illegal_param_csc"
            case accountClosed = "account_closed"
            case illegalParamExtAuthSuccessUri = "illegal_param_ext_auth_success_uri"
            case illegalParamExtAuthFailUri = "illegal_param_ext_auth_fail_uri"
            case illegalParamRequestId = "illegal_param_request_id"
            case illegalParamMoneySourceToken = "illegal_param_money_source_token"
            case illegalParamClientId = "illegal_param_client_id"
        }

        enum Search: String {
            case illegalParamQuery = "illegal_param_query"
            case illegalParamRecordsLimit = "illegal_param_records"
            case illegalParamOperationType = "illegal_param_type"
        }

        enum Personification: String {
            case accountAlreadyIdentified = "account_already_identified"
            case personificationRefused = "personification_refused"
        }
    }
}

// MARK: - LocalizedError
extension ApiResponseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        // MARK: Status 200
        case .orderRefused: return "Refused by merchant or no payment method available"
        case .authorizationRejected: return "Payment authorization rejected"
        case .alreadyAuthorized: return "Order already authorized"
        case .inappropriateStatus(status: let status): return "Operation not alowed for order with status '\(status)'"
        case .orderExpired: return "Trying to pay expired order"
        case .identificationRequired: return "User identification required. Order finally rejected"
        case .accountAlreadyIdentified: return "Account already identified"
        case .personificationRefused: return "Operation of personification refused. Incorrect personification data"
        case .recipientAccountClosed: return "Recipient account closed"
        case .insufficientFunds: return "Not enough funds for this order"
        case .operationNotSupported: return "Operation not supported for this order"
        case .partialRefundNotAllowed: return "Partial refund not allowed for this order type"
        case .illegalParameters: return "Merchant rejected parameters"
        case .payerNotFound: return "Payer account not found in merchant's regester"

        // MARK: Status 202
        case .requestStateUnknown(nextRetry: let nextRetry):
            return "Request state unknown and should be repeated to get final state. Retry in \(nextRetry) ms"

        // MARK: Status 400
        case .syntaxError: return "HTTP request or JWS parsing failed"
        case .illegalHeader(parameterName: let parameterName):
            return "JWS header missing or holds illegal values for '\(parameterName)'"
        case .illegalParameter(parameterName: let parameterName):
            return "JWS payload missing or holds illegal values for '\(parameterName)'"
        case .intervalTooLarge(parameterName: let parameterName):
            return "Too large selection interval requested for '\(parameterName)'"
        case .orderDuplication: return "Tryng to create different order with previously user order ID"
        case .amountRemainderTooLow:
            return "Not allowed partial refund amount. Partial amount should be reduced or total amount refunded"

        // MARK: Status 401
        case .invalidToken: return "OAuth2 wallet authorization invalid"
        case .illegalSignature: return "Illegal JWS signature"

        // MARK: Status 403
        case .sourceNotAllowed: return "Source not allowed for this order now"
        case .methodNotAllowed: return "Method not allowed for this order"
        case .recipientNotAllowed: return "Transfers to payee not allowed, merchant disabled or blocked"
        case .instrumentNotAllowed: return "Order not allowed to be paid by this instrument"
        case .operationForbidden: return "Requested operation forbidden for this order"
        case .invalidScope: return "OAuth2 authorization scope not enough for requested operation"
        case .parameterNotAllowed(parameterName: let parameterName):
            return "Parameter value not allowed for '\(parameterName)'"

        // MARK: Status 500
        case .technicalError(nextRetry: let nextRetry):
            // swiftlint:disable:next line_length
            return "Technical Error. Request accepted or rejected, and should be repeated to get final status. Retry in \(nextRetry) ms"

        // MARK: OAuth2 API
        case .phoneNumberRefused: return "Phone number not allowed for Yandex.Wallet registration"
        case .applicationBlocked: return "Instance ID or Client ID not allowed for Yandex.Wallet registration"
        case .alreadyExists: return "Yandex.Wallet for current account arleady exists"
        case .linkedPhoneRequired: return "No phone linked for this account"
        case .limitExceeded: return "Phone number validation retries limit temporary exceeded"

        // MARK: API v1 payments
        case .accountBlocked(uri: let uri): return "User account blocked. To unlock procceed to: " + uri
        case .extActionRequired(uri: let uri):
            return "Requested payment not allowed until action on external page proceeded: " + uri

        // MARK: Undefined
        case .unknown(let desctiption): return "Undefined error. " + desctiption
        }
    }
}
