import Foundation
import RequestResponse

/// Archive API (Native BL `v1/archive/*`).
public enum ArchiveApi {
    /// Endpoint: `GET /v1/archive/history2`
    ///
    /// Returns available history intervals for a source. Response may be partial; see `HistoryResponse.result`.
    public static func history2(_ request: HistoryRequest) -> Request<Data> {
        Request(
            path: "v1/archive/history2",
            method: .get,
            query: [
                ("access_point", request.accessPoint),
                ("begin_time", String(request.beginTimeMs)),
                ("end_time", String(request.endTimeMs)),
                ("max_count", String(request.maxCount)),
                ("min_gap_ms", String(request.minGapMs)),
                ("scan_mode", request.scanMode.rawValue),
            ]
        )
    }

    /// Endpoint: `GET /v1/archive/calendar`
    ///
    /// Returns days that contain records for a source.
    public static func calendar(
        accessPoint: AccessPoint,
        begin: Date,
        end: Date
    ) -> Request<Data> {
        Request(
            path: "v1/archive/calendar",
            method: .get,
            query: [
                ("access_point", accessPoint),
                ("begin_time", String(ArchiveTime.millisecondsSince1900(begin))),
                ("end_time", String(ArchiveTime.millisecondsSince1900(end))),
            ]
        )
    }

    /// Archive depth via `GET /v1/archive/calendar` on a wide range.
    ///
    /// Decode `CalendarResponse` and read ``CalendarResponse/depth`` for outer bounds.
    public static func depth(
        accessPoint: AccessPoint,
        begin: Date,
        end: Date
    ) -> Request<Data> {
        calendar(accessPoint: accessPoint, begin: begin, end: end)
    }

    /// Endpoint: `GET /v1/archive/size`
    ///
    /// Returns disk usage and playback duration for a time interval.
    public static func size(
        accessPoint: AccessPoint,
        beginTime: String,
        endTime: String
    ) -> Request<Data> {
        Request(
            path: "v1/archive/size",
            method: .get,
            query: [
                ("access_point", accessPoint),
                ("begin_time", beginTime),
                ("end_time", endTime),
            ]
        )
    }

    /// Endpoint: `GET /v1/archive/recordingInfo`
    public static func recordingInfo(
        accessPoint: AccessPoint,
        updateCache: Bool = false
    ) -> Request<Data> {
        Request(
            path: "v1/archive/recordingInfo",
            method: .get,
            query: [
                ("access_point", accessPoint),
                ("update_cache", updateCache ? "true" : "false"),
            ]
        )
    }

    /// Endpoint: `GET /v1/archive/volumes/state`
    ///
    /// Returns current state of storage volumes. Pass empty `volumeIds` to request all volumes.
    public static func volumesState(
        accessPoint: AccessPoint,
        volumeIds: [String] = []
    ) -> Request<Data> {
        var query: [(String, String?)] = [
            ("access_point", accessPoint),
        ]
        for id in volumeIds {
            query.append(("volume_ids", id))
        }
        return Request(
            path: "v1/archive/volumes/state",
            method: .get,
            query: query
        )
    }
}
