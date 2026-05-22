import Foundation

/// Response for `GET /v1/archive/volumes/state` (`GetVolumesStateResponse`).
public struct GetVolumesStateResponse: Decodable, Equatable, Sendable {
    public let volumesState: [String: VolumeState]
    public let notFoundVolumes: [String]
    public let isFailoverMode: Bool
    public let isTemporaryStorage: Bool

    private enum CodingKeys: String, CodingKey {
        case volumesState = "volumes_state"
        case notFoundVolumes = "not_found_volumes"
        case isFailoverMode = "is_failover_mode"
        case isTemporaryStorage = "is_temporary_storage"
    }
}
