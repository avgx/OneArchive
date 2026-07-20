import Foundation
import OneWireFormat

/// Response for `GET /archive/contents/frames/{VIDEOSOURCEID}/{ENDTIME}/{BEGINTIME}`.
public struct FramesResponse: Decodable, Equatable, Sendable {
    /// Frame registration times in UTC (server wire order).
    public let frames: [Date]
    /// `true` when the server returned every frame in the range; `false` when truncated by `limit`.
    ///
    /// Note: some server docs invert this flag relative to `archive/contents/intervals`.
    public let more: Bool

    private enum CodingKeys: String, CodingKey {
        case frames
        case more
    }

    public init(frames: [Date], more: Bool) {
        self.frames = frames
        self.more = more
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let wireFrames = try container.decode([String].self, forKey: .frames)
        frames = try wireFrames.map { string in
            guard let date = Timestamp.utc.date(from: string) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .frames,
                    in: container,
                    debugDescription: "Invalid frame timestamp: \(string)"
                )
            }
            return date
        }
        more = try container.decode(Bool.self, forKey: .more)
    }
}
