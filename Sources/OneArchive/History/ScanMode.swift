import Foundation

/// Scan mode for `GET /v1/archive/history2` (`GetHistory2Request.EScanMode`).
public enum ScanMode: String, Codable, Hashable, Sendable {
    /// Exact history lookup; may take a while on large intervals with sparse records.
    case exact = "SM_EXACT"
    /// Quick and approximate lookup.
    case approximate = "SM_APPROXIMATE"
}
