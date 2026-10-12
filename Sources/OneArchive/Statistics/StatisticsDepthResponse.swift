import Foundation
import OneWireFormat

/// Response for `GET /archive/statistics/depth/{VIDEOSOURCEID}`.
///
/// `start` and `end` are absent when the server has no bounded depth for the requested threshold.
public struct StatisticsDepthResponse: Decodable, Equatable, Sendable {
    public let start: Date?
    public let end: Date?

    private enum CodingKeys: String, CodingKey {
        case start
        case end
    }

    public init(start: Date?, end: Date?) {
        self.start = start
        self.end = end
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try Self.date(container.decodeIfPresent(String.self, forKey: .start), forKey: .start, in: container)
        end = try Self.date(container.decodeIfPresent(String.self, forKey: .end), forKey: .end, in: container)
    }

    private static func date(
        _ string: String?,
        forKey key: CodingKeys,
        in container: KeyedDecodingContainer<CodingKeys>
    ) throws -> Date? {
        guard let string else { return nil }
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
