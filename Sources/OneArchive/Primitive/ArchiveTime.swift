import Foundation

/// Native BL archive timestamps: milliseconds since **1900-01-01 00:00:00.000 UTC**.
public enum ArchiveTime {
    private static var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    /// `1900-01-01 00:00:00.000 UTC`
    public static let epoch1900: Date = {
        var components = DateComponents()
        components.year = 1900
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        return utc.date(from: components)!
    }()

    public static func millisecondsSince1900(_ date: Date) -> Int64 {
        Int64(date.timeIntervalSince(epoch1900) * 1000)
    }

    public static func date(millisecondsSince1900 ms: Int64) -> Date {
        Date(timeIntervalSince1970: epoch1900.timeIntervalSince1970 + TimeInterval(ms) / 1000)
    }

    /// UTC start of the calendar day that contains `date`.
    public static func startOfUTCDay(_ instant: Date) -> Date {
        let ms = millisecondsSince1900(instant)
        return Self.date(millisecondsSince1900: ms - ms % 86_400_000)
    }

    /// Start of the UTC day after the day that contains `instant` (exclusive upper bound).
    public static func endOfUTCDay(_ instant: Date) -> Date {
        utc.date(byAdding: .day, value: 1, to: startOfUTCDay(instant)) ?? instant
    }
}
