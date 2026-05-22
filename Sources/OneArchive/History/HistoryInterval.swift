import Foundation

/// Single recorded interval (`HistoryResponse` interval).
public struct HistoryInterval: Decodable, Equatable, Sendable {
    public let begin: Date
    public let end: Date

    private enum CodingKeys: String, CodingKey {
        case begin = "begin_time"
        case end = "end_time"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        begin = ArchiveTime.date(
            millisecondsSince1900: try container.decode(ArchiveWireInt64.self, forKey: .begin).value
        )
        end = ArchiveTime.date(
            millisecondsSince1900: try container.decode(ArchiveWireInt64.self, forKey: .end).value
        )
    }
}
