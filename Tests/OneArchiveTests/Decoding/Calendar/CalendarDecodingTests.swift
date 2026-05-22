import Foundation
import Testing
@testable import OneArchive

@Suite("Calendar decoding")
struct CalendarDecodingTests {
    private let decoder = JSONDecoder()

    @Test("decode days as dates from fixture")
    func decode_from_fixture() throws {
        let data = try FixtureLoader.loadData(resource: "v1_archive_calendar")
        let response = try decoder.decode(CalendarResponse.self, from: data)
        #expect(response.days.count == 5)
        #expect(
            response.days[0]
                == ArchiveTime.date(millisecondsSince1900: 3_961_353_600_000)
        )
    }

    @Test("depth spans first through last recorded day")
    func depth_from_fixture() throws {
        let data = try FixtureLoader.loadData(resource: "v1_archive_calendar")
        let response = try decoder.decode(CalendarResponse.self, from: data)
        let depth = try #require(response.depth)
        #expect(depth.begin == response.days.min())
        #expect(depth.end == ArchiveTime.endOfUTCDay(try #require(response.days.max())))
    }
}
