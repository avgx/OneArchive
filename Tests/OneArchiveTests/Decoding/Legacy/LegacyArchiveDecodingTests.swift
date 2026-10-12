import Foundation
import OneWireFormat
import Testing
@testable import OneArchive

@Suite("Legacy archive decoding")
struct LegacyArchiveDecodingTests {
    private let decoder = JSONDecoder()

    @Test("decode statistics depth fixture")
    func decode_statistics_depth() throws {
        let data = try FixtureLoader.loadData(resource: "archive_statistics_depth")
        let response = try decoder.decode(StatisticsDepthResponse.self, from: data)
        #expect(response.start == Timestamp.utc.date(from: "20261005T061040.795000"))
        #expect(response.end == Timestamp.utc.date(from: "20261012T111241.642000"))
    }

    @Test("decode statistics depth without bounds")
    func decode_statistics_depth_empty() throws {
        let response = try decoder.decode(StatisticsDepthResponse.self, from: Data("{}".utf8))
        #expect(response.start == nil)
        #expect(response.end == nil)
    }

    @Test("decode contents intervals fixture")
    func decode_contents_intervals() throws {
        let data = try FixtureLoader.loadData(resource: "archive_contents_intervals")
        let response = try decoder.decode(ContentsIntervalsResponse.self, from: data)
        #expect(response.more == true)
        #expect(response.intervals.count == 3)
        #expect(response.intervals[0].begin == Timestamp.utc.date(from: "20261005T000000.000000"))
        #expect(response.intervals[0].end == Timestamp.utc.date(from: "20261005T010000.000000"))
        #expect(response.intervals[1].begin == Timestamp.utc.date(from: "20261006T120000"))
        #expect(response.intervals[1].end == Timestamp.utc.date(from: "20261006T130000.500000"))
        #expect(response.intervals[2].begin == Timestamp.utc.date(from: "20261007T080000.795000"))
        #expect(response.intervals[2].end == Timestamp.utc.date(from: "20261007T090000.111000"))
        #expect(response.intervals[0].end > response.intervals[0].begin)
    }

    @Test("decode empty contents intervals")
    func decode_contents_intervals_empty() throws {
        let json = #"{"intervals":[],"more":false}"#
        let response = try decoder.decode(ContentsIntervalsResponse.self, from: Data(json.utf8))
        #expect(response.intervals.isEmpty)
        #expect(response.more == false)
    }
}
