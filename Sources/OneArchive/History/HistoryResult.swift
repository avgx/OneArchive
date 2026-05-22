import Foundation

/// Result status for `GET /v1/archive/history2` (`GetHistory2Response.EResult`).
public enum HistoryResult: String, Codable, Hashable, Sendable {
    /// Complete result for the requested time range.
    case full = "FULL"
    /// Partial result; client may retry with a narrower range.
    case partial = "PARTIAL"
    /// Request cannot be satisfied at the moment; client should retry later.
    case tryLater = "TRY_LATER"
}
