import Foundation
import SafeEnum

/// Response for `GET /v1/archive/history2` (`GetHistory2Response`).
public struct HistoryResponse: Decodable, Equatable, Sendable {
    public let result: SafeEnum<HistoryResult>
    public let intervals: [HistoryInterval]

    private enum CodingKeys: String, CodingKey {
        case result
        case intervals
    }
}
