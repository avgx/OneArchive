import Foundation

/// Outermost span of days that contain archive records (derived from `GET /v1/archive/calendar`).
public struct ArchiveDepth: Equatable, Sendable {
    public let begin: Date
    /// Start of the UTC day after the last recorded day (exclusive upper bound).
    public let end: Date
}
