import Foundation

/// Volume lifecycle state (`VolumeState.EState`).
public enum VolumeStateCode: String, Codable, Hashable, Sendable {
    case unspecified = "STATE_UNSPECIFIED"
    case opening = "OPENING"
    case formatting = "FORMATTING"
    case unmounted = "UNMOUNTED"
    case mounted = "MOUNTED"
    case errorState = "ERROR_STATE"
    case fileErrorState = "FILE_ERROR_STATE"
    case inMaintenance = "IN_MAINTENANCE"
}
