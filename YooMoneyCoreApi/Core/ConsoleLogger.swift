/// Console Logger.
public struct ConsoleLogger {

    /// Creates a new instance.
    public init() { }
}

extension ConsoleLogger: Logger {
    public func log(message: String) {
        print("[YooMoneyCoreApi] \(message)")
    }
}
