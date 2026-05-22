import Foundation

/// JSON scalar that may be encoded as a number or a decimal string.
public struct ArchiveWireUInt64: Codable, Equatable, Sendable, Hashable {
    public let value: UInt64

    public init(_ value: UInt64) {
        self.value = value
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let number = try? container.decode(UInt64.self) {
            value = number
            return
        }
        let string = try container.decode(String.self)
        guard let number = UInt64(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected UInt64 or numeric string"
            )
        }
        value = number
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
