# YooMoney Core API library

[![Build Status](https://travis-ci.org/yoomoney/yoomoney-core-api-swift.svg?branch=master)](https://travis-ci.org/yoomoney/yoomoney-core-api-swift)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub tag](https://img.shields.io/github/tag/yoomoney/yoomoney-core-api-swift.svg)](https://img.shields.io/github/tag/yoomoney/yoomoney-core-api-swift.svg)
[![CocoaPods](https://img.shields.io/cocoapods/v/yoomoney/yoomoney-core-api-swift.svg)](https://img.shields.io/cocoapods/v/yoomoney/yoomoney-core-api-swift.svg)
[![CocoaPods](https://img.shields.io/cocoapods/at/yoomoney/yoomoney-core-api-swift.svg)](https://img.shields.io/cocoapods/at/yoomoney/yoomoney-core-api-swift.svg)
[![license](https://img.shields.io/github/license/yoomoney/yoomoney-core-api-swift.svg)](https://img.shields.io/github/license/yoomoney/yoomoney-core-api-swift.svg)


### Concept

#### ApiSession

`ApiSession` - слой абстракции над `URLSession`. `ApiSession` может выполнять `ApiMethod`, 
отменять все запущенные запросы.

Для создания новой сессии необходимо создать `HostProvider`. `HostProvider` - интерфейс, который умеет
по ключу отдавать необходимый хост. Можно относиться к нему, как к словарю, который зает имена хостов и
их значения.

> Если вы работаете с тестовыми средами, то вы можете реализовать отдельный `HostProvider`, который будет
> вести все методы сессии не на боевую среду, а на тестовую. И в зависимости от среды просто внедрять
> разный `HostProvider` в `ApiSession`.
#### ApiMethod

`ApiMethod` - модель вашего запроса на сервер. Каждому `ApiMethod` должен быть выставлен свой `Response`.
=> для каждого метода можно описать только один ответ от сервера.

Для реализации `ApiMethod` вам необходимо определить следующие свойства:

* `hostProviderKey` - ключ по которому `HostProvider` должен вам вернуть host для запроса.
* `httpMethod` - метод HTTP протокола (например: `.post`, `.get`).
* `parametersEncoding` - `Encoder` параметров. В CoreApi доступны уже 2 готовых `Encoder`: `JsonParametersEncoder` и `QueryParametersEncoder`.

И метод:
* `urlInfo(from hostProvider: HostProvider) throws -> URLInfo` - который при помощи `HostProvider` вернет `URL` запроса.

> Рекомендуется использовать в этом методе свойство `hostProviderKey`, если только url вам не пришёл извне.
 
Опционально:
* `headers` - структура хранящая заголовки для запроса.

`ApiMethod` должен реализовывать протокол `Encodable`. Всё, что кодируется в методе `encode(to:)` будет
отправлено в `parametersEncoding` и встроено в соответствующую часть запроса. 

> К примеру ели вы используете `QueryParametersEncoder`, то данные попадут в query параметры строки, а при
> использовании `JsonParametersEncoder` они попадут в тело запроса в формате json
#### ApiResponse

`ApiResponse` - модель ответа от сервера. Для большего удобства рекомендуется отнаследоваться от этого 
интерфейса и создать свой. 

> Приведем пример. У вас может быть несколько различных api и каждый из них отдает свои специфические ошибки
> или ошибки в своём формате. в итоге под каждое Api вы делаете свой протокол отнаследованный от `ApiResponse`
> и определяете там свои методы `process` и `makeResponse`. В итоге вам ненужно реализовывать в каждой модели
> одни и те же обработчики ошибок.
Приведем пример реализации своего протокола на базе `ApiResponse`.

```swift
public protocol WalletApiResponse: ApiResponse {}
extension WalletApiResponse {
    public static func process(response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<Self> {
        var result: Result<Self>
        if let response = response,
           let data = data,
           let error = WalletAuthApiError.makeResponse(response: response, data: data) {
            result = .left(error)
        } else if let response = response,
                  let data = data,
                  let error = self.makeSpecificError(response: response, data: data) {
            result = .left(error)
        } else if let response = response,
                  let data = data,
                  let serializedData = self.makeResponse(response: response, data: data) {
            result = .right(serializedData)
        } else if let error = error {
            result = .left(error)
        } else {
            result = .left(WalletApiError.mappingError)
        }
        return result
    }
}
```

В данном примере сначал мы:
1. Пробуем распарсить общую ошибку api. 
2. Пробуем распарсить ошибку специфичную для метода api
3. Пробуем распарсить ответ от сервера
4. Если произошла ошибка `ApiSession`, то возвращаем её
5. Если ничего распарсить не получилось и ошибки слоя `ApiSession` не произошло, то возвращаем ошибку маппинга. 

Для того, чтобы не реализовывать в каждой ошибке и в каждом ответе метод `makeResponse(response:data:)`
есть несколько вспомогательных протоколов:

* `JsonApiResponse` - пытается из `data` получить модель путем использования протокола `Decodable`
* `TextApiResponse` - конвертит `data` в utf8 строку и вызывает инициализатор `init?(text:)`. Если `response` содержит
`textEncodingName`, то вместо utf8 будет использоваться кодировка ответа от сервера.

Вы так же можете создать свой протокол и реализовать у него метод `makeResponse(response:data:)`, если
ни один из стандартных протоколов вам не подошёл. К примеру если вам надо парсить XML при ответе.

#### Пример

Пример интеграции в проект можно посмотреть [тут](https://github.com/yoomoney/yookassa-payments-api-swift/blob/master/YooKassaPaymentsApi/Source/Response/PaymentsApiResponse.swift).

```swift
/// Модель ответа от сервера.
public struct PaymentMethod {
    public let type: PaymentMethodType
    public let id: String
    public init(type: PaymentMethodType,
                id: String) {
        self.type = type
        self.id = id
    }
    /// Модель запроса на сервер.
    public struct Method {
        public let oauthToken: String
        public init(oauthToken: String) {
            self.oauthToken = oauthToken
        }
    }
}
// Парсим ответ от сервера.
extension PaymentMethod: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(PaymentMethodType.self, forKey: .type)
        let id = try container.decode(String.self, forKey: .id)
        self.init(
            type: type,
            id: id
        )
    }
    private enum CodingKeys: String, CodingKey {
        case type
        case id
    }
}
// Реализовываем ApiResponse для модели ответа.
extension PaymentMethod: PaymentsApiResponse, JsonApiResponse {}
// Реализовываем ApiMethod для модели запроса.
extension PaymentMethod.Method: ApiMethod {
    public typealias Response = PaymentMethod
    public var hostProviderKey: String {
        return Constants.paymentsApiMethodsKey
    }
    public var httpMethod: HTTPMethod {
        return .get
    }
    public var parametersEncoding: ParametersEncoding {
        return QueryParametersEncoder()
    }
    public var headers: Headers {
        let headers = Headers([
            AuthorizationConstants.authorization: AuthorizationConstants.basicAuthorizationPrefix + oauthToken,
        ])
        return headers
    }
    public func urlInfo(from hostProvider: HostProvider) throws -> URLInfo {
        return .components(host: try hostProvider.host(for: hostProviderKey),
                           path: "/payment_method")
    }
}
// Перегружаем стандартные `encode(to:)` и `init(from:)` чтобы поле `oauthToken` не попало в 
// query параметры.
extension PaymentMethod.Method: Encodable, Decodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(oauthToken: "")
    }
    private enum CodingKeys: String, CodingKey {}
}
```