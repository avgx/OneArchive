import Foundation

/// Response for `GET /v1/archive/calendar` (`GetCalendarResponse`).
public struct CalendarResponse: Decodable, Equatable, Sendable {
    /// UTC start of each day that contains records.
    public let days: [Date]

    /// Outermost bounds from calendar days, or `nil` when `days` is empty.
    public var depth: ArchiveDepth? {
        guard let first = days.min(), let last = days.max() else { return nil }
        return ArchiveDepth(
            begin: ArchiveTime.startOfUTCDay(first),
            end: ArchiveTime.endOfUTCDay(last)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case days
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let wireDays = try container.decode([ArchiveWireInt64].self, forKey: .days)
        days = wireDays.map { ArchiveTime.date(millisecondsSince1900: $0.value) }
    }
}
