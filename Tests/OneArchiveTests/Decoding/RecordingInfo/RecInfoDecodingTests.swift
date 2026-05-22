import Foundation
import Testing
@testable import OneArchive

@Suite("RecInfo decoding")
struct RecInfoDecodingTests {
    private let decoder = JSONDecoder()

    @Test("decode recording_info from fixture")
    func decode_from_fixture() throws {
        let data = try FixtureLoader.loadData(resource: "v1_archive_recording_info")
        let response = try decoder.decode(RecInfoResponse.self, from: data)
        let info = try #require(response.recordingInfo)
        #expect(info.recordingSize == 203_184)
        #expect(info.capacity == 204_800)
    }
}
