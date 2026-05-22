import Foundation

/// JSON scalar that may be encoded as a number or a decimal string.
public struct ArchiveWireInt64: Codable, Equatable, Sendable, Hashable {
    public let value: Int64

    public init(_ value: Int64) {
        self.value = value
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let number = try? container.decode(Int64.self) {
            value = number
            return
        }
        let string = try container.decode(String.self)
        guard let number = Int64(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected Int64 or numeric string"
            )
        }
        value = number
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
