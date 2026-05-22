import Foundation
import Testing
@testable import OneArchive

@Suite("Size decoding")
struct SizeDecodingTests {
    private let decoder = JSONDecoder()

    @Test("decode size and duration as numeric strings")
    func decode_from_fixture() throws {
        let data = try FixtureLoader.loadData(resource: "v1_archive_size")
        let response = try decoder.decode(SizeResponse.self, from: data)
        #expect(response.size == 1_048_576)
        #expect(response.duration == 3_600)
    }
}
