import Foundation
import Testing
@testable import OneArchive

@Suite("GetVolumesState decoding")
struct GetVolumesStateDecodingTests {
    private let decoder = JSONDecoder()

    @Test("decode volumes_state from fixture")
    func decode_from_fixture() throws {
        let data = try FixtureLoader.loadData(resource: "v1_archive_volumes_state")
        let response = try decoder.decode(GetVolumesStateResponse.self, from: data)
        #expect(response.isFailoverMode == false)
        #expect(response.notFoundVolumes.isEmpty)
        let volume = try #require(response.volumesState["D:/archiveAliceBlue.afs"])
        #expect(volume.state.value == .mounted)
        #expect(volume.progress == 100)
        #expect(volume.usedBytes == 214_748_364_800)
    }
}
