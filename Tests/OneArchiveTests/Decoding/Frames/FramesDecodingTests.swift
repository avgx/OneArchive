import Foundation
import OneWireFormat
import Testing
@testable import OneArchive

@Suite("Frames decoding")
struct FramesDecodingTests {
    private let decoder = JSONDecoder()

    @Test("decode frames fixture from docs sample")
    func decode_fixture() throws {
        let data = try FixtureLoader.loadData(resource: "archive_contents_frames")
        let response = try decoder.decode(FramesResponse.self, from: data)
        #expect(response.more == true)
        #expect(response.frames.count == 3)

        let first = try #require(Timestamp.utc.date(from: "20200525T113229.649000"))
        let last = try #require(Timestamp.utc.date(from: "20200525T113228.588000"))
        #expect(response.frames[0] == first)
        #expect(response.frames[2] == last)
        #expect(response.frames[0] > response.frames[1])
        #expect(response.frames[1] > response.frames[2])
    }

    @Test("decode empty frames")
    func decode_empty() throws {
        let json = #"{"frames":[],"more":false}"#
        let response = try decoder.decode(FramesResponse.self, from: Data(json.utf8))
        #expect(response.frames.isEmpty)
        #expect(response.more == false)
    }
}
