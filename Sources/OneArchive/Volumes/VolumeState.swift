import Foundation
import SafeEnum

/// Current state and statistics of a storage volume (`VolumeState`).
public struct VolumeState: Decodable, Equatable, Sendable {
    public let state: SafeEnum<VolumeStateCode>
    public let readonly: Bool
    /// Progress in percent when applicable.
    public let progress: Int?
    public let usedBytes: UInt64
    public let capacityBytes: UInt64
    public let isEncrypted: Bool
    public let isValidEncryptedKey: Bool
    public let usedBytesProtected: UInt64

    private enum CodingKeys: String, CodingKey {
        case state
        case readonly
        case progress
        case usedBytes = "used_bytes"
        case capacityBytes = "capacity_bytes"
        case isEncrypted = "is_encrypted"
        case isValidEncryptedKey = "is_valid_encrypted_key"
        case usedBytesProtected = "used_bytes_protected"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        state = try container.decode(SafeEnum<VolumeStateCode>.self, forKey: .state)
        readonly = try container.decode(Bool.self, forKey: .readonly)
        progress = try container.decodeIfPresent(Int.self, forKey: .progress)
        usedBytes = try container.decode(ArchiveWireUInt64.self, forKey: .usedBytes).value
        capacityBytes = try container.decode(ArchiveWireUInt64.self, forKey: .capacityBytes).value
        isEncrypted = try container.decode(Bool.self, forKey: .isEncrypted)
        isValidEncryptedKey = try container.decode(Bool.self, forKey: .isValidEncryptedKey)
        usedBytesProtected = try container.decodeIfPresent(ArchiveWireUInt64.self, forKey: .usedBytesProtected)?.value ?? 0
    }
}
