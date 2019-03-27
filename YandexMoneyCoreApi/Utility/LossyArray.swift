import Foundation

// TODO: - Remove it when Swift issue resolved: https://bugs.swift.org/browse/SR-5953

/// Decodable container for array of Decodable elements.
/// Doesn't fail decoding if one or few elements failed to decode.
/// Useful for API response backward compatibility.
///
/// Usage example:
/// ```
/// let models = try decoder.decode(LossyArray<Model>.self,
///                                 from: jsonData).elements
/// ```
public struct LossyArray<Element: Decodable>: Decodable {

    /// Decoded elements.
    public let elements: [Element]

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements: [Element] = []
        container.count.map { elements.reserveCapacity($0) }
        while container.isAtEnd == false {
            if let element = try? container.decode(Element.self) {
                elements.append(element)
            } else {
                _ = try container.decode(Dummy.self)
            }
        }
        self.elements = elements
    }

    private struct Dummy: Decodable { }
}
