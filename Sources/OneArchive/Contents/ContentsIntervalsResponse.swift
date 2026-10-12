import Foundation
import OneWireFormat

/// One recorded span from `GET /archive/contents/intervals/...`.
public struct ContentsInterval: Decodable, Equatable, Sendable {
    public let begin: Date
    public let end: Date

    private enum CodingKeys: String, CodingKey {
        case begin
        case end
    }

    public init(begin: Date, end: Date) {
        self.begin = begin
        self.end = end
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        begin = try Self.date(container.decode(String.self, forKey: .begin), forKey: .begin, in: container)
        end = try Self.date(container.decode(String.self, forKey: .end), forKey: .end, in: container)
    }

    private static func date(
        _ string: String,
        forKey key: CodingKeys,
        in container: KeyedDecodingContainer<CodingKeys>
    ) throws -> Date {
        guard let date = Timestamp.utc.date(from: string) else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: container,
                debugDescription: "Invalid archive timestamp: \(string)"
            )
        }
        return date
    }
}

/// Response for `GET /archive/contents/intervals/{VIDEOSOURCEID}/{ENDTIME}/{BEGINTIME}`.
public struct ContentsIntervalsResponse: Decodable, Equatable, Sendable {
    public let intervals: [ContentsInterval]
    /// `true` when further intervals exist beyond `limit`.
    public let more: Bool

    public init(intervals: [ContentsInterval], more: Bool) {
        self.intervals = intervals
        self.more = more
    }
}
