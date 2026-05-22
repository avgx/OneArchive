import Foundation
import Testing
@testable import OneArchive

@Suite("ArchiveTime")
struct ArchiveTimeTests {
    @Test("round-trip milliseconds since 1900")
    func round_trip() {
        let ms: Int64 = 3_961_353_600_000
        let date = ArchiveTime.date(millisecondsSince1900: ms)
        #expect(ArchiveTime.millisecondsSince1900(date) == ms)
    }
}
