import Foundation

/// Response for `GET /v1/archive/size` (`GetSizeResponse`).
public struct SizeResponse: Decodable, Equatable, Sendable {
    /// Disk usage in bytes.
    public let size: Int64
    /// Stored playback duration in seconds.
    public let duration: Int64

    private enum CodingKeys: String, CodingKey {
        case size
        case duration
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        size = try container.decode(ArchiveWireInt64.self, forKey: .size).value
        duration = try container.decode(ArchiveWireInt64.self, forKey: .duration).value
    }
}
