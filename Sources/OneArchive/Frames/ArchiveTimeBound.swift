import Foundation
import OneWireFormat

/// Path bound for legacy archive contents endpoints (`past` / `future` / UTC instant).
public enum ArchiveTimeBound: Sendable, Hashable {
    case past
    case future
    case instant(Date)

    /// Path segment for `archive/contents/frames/.../{end}/{begin}`.
    public var pathSegment: String {
        switch self {
        case .past:
            "past"
        case .future:
            "future"
        case .instant(let date):
            Timestamp.utc.string(from: date)
        }
    }
}
