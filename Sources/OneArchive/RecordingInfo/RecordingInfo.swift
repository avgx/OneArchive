import Foundation

/// Recording statistics (`RecInfoResponse.RecordingInfo`).
public struct RecordingInfo: Decodable, Equatable, Sendable {
    public let systemSize: Int64
    public let recordingSize: Int64
    public let recordingRate: Int64
    public let capacity: Int64
    public let lastUpdate: Date

    private enum CodingKeys: String, CodingKey {
        case systemSize = "system_size"
        case recordingSize = "recording_size"
        case recordingRate = "recording_rate"
        case capacity
        case lastUpdate = "last_update"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        systemSize = try container.decode(ArchiveWireInt64.self, forKey: .systemSize).value
        recordingSize = try container.decode(ArchiveWireInt64.self, forKey: .recordingSize).value
        recordingRate = try container.decode(ArchiveWireInt64.self, forKey: .recordingRate).value
        capacity = try container.decode(ArchiveWireInt64.self, forKey: .capacity).value
        let lastUpdateMs = try container.decode(ArchiveWireInt64.self, forKey: .lastUpdate).value
        lastUpdate = Date(timeIntervalSince1970: TimeInterval(lastUpdateMs))
    }
}
