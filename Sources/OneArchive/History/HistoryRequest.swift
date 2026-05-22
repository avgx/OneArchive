import Foundation

/// Query parameters for `GET /v1/archive/history2` (`GetHistory2Request`).
public struct HistoryRequest: Equatable, Sendable {
    public let accessPoint: AccessPoint
    public let begin: Date
    public let end: Date
    public let maxCount: UInt32
    public let minGapMs: UInt64
    public let scanMode: ScanMode

    public init(
        accessPoint: AccessPoint,
        begin: Date,
        end: Date,
        maxCount: UInt32,
        minGapMs: UInt64,
        scanMode: ScanMode
    ) {
        self.accessPoint = accessPoint
        self.begin = begin
        self.end = end
        self.maxCount = maxCount
        self.minGapMs = minGapMs
        self.scanMode = scanMode
    }

    var beginTimeMs: Int64 { ArchiveTime.millisecondsSince1900(begin) }
    var endTimeMs: Int64 { ArchiveTime.millisecondsSince1900(end) }
}
