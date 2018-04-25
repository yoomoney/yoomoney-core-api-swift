import Foundation

extension URLRequest {

    /// Creates an instance with the specified `method`, `urlString` and `headers`.
    ///
    /// - parameter url:     The URL.
    /// - parameter method:  The HTTP method.
    /// - parameter headers: The HTTP headers. `nil` by default.
    ///
    /// - returns: The new `URLRequest` instance.
    public init(url: URL, method: HTTPMethod, headers: Headers? = nil) {
        self.init(url: url)

        httpMethod = method.rawValue

        if let headers = headers {
            for (headerField, headerValue) in headers.value {
                setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
    }
}
