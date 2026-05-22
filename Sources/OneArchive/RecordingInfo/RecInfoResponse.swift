import Foundation

/// Response for `GET /v1/archive/recordingInfo` (`RecInfoResponse`).
public struct RecInfoResponse: Decodable, Equatable, Sendable {
    public let recordingInfo: RecordingInfo?

    private enum CodingKeys: String, CodingKey {
        case recordingInfo = "recording_info"
    }
}
