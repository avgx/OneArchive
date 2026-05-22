import Foundation
import Testing
@testable import OneArchive

@Suite("History decoding")
struct HistoryDecodingTests {
    private let decoder = JSONDecoder()

    @Test("decode wide approximate partial from fixture")
    func decode_wide_approx() throws {
        let data = try FixtureLoader.loadData(resource: "v1_archive_history2_wide_approx")
        let response = try decoder.decode(HistoryResponse.self, from: data)
        #expect(response.result.value == .partial)
        #expect(response.intervals.count == 3)
        #expect(
            response.intervals[0].begin
                == ArchiveTime.date(millisecondsSince1900: 3_961_369_121_412)
        )
    }

    @Test("decode exact one-hour full from fixture")
    func decode_exact_1h() throws {
        let data = try FixtureLoader.loadData(resource: "v1_archive_history2_exact_1h")
        let response = try decoder.decode(HistoryResponse.self, from: data)
        #expect(response.result.value == .full)
        #expect(response.intervals.count == 1)
        #expect(response.intervals[0].end > response.intervals[0].begin)
    }

    @Test("decode empty full inline")
    func decode_empty_full() throws {
        let json = #"{"result":"FULL","intervals":[]}"#
        let response = try decoder.decode(HistoryResponse.self, from: Data(json.utf8))
        #expect(response.result.value == .full)
        #expect(response.intervals.isEmpty)
    }
}
