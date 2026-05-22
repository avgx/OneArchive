import Foundation
import Testing
@testable import OneArchive

enum FixtureLoader {
    static func loadData(resource: String, ext: String = "json") throws -> Data {
        let url = try #require(Bundle.module.url(forResource: resource, withExtension: ext))
        return try Data(contentsOf: url)
    }
}
