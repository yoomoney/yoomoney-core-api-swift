/// Logs messages about unexpected behavior.
public protocol Logger {

    /// Logs provided message.
    ///
    /// - Parameters:
    ///   - message: message to log
    func log(message: String)
}
