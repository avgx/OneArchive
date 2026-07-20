import Foundation
import OneWireFormat
import RequestResponse

/// Archive API (Native BL `v1/archive/*`).
public enum ArchiveApi {
    /// Endpoint: `GET /v1/archive/history2`
    ///
    /// Returns available history intervals for a source. Response may be partial; see `HistoryResponse.result`.
    public static func history2(_ parameters: HistoryRequest) -> Request<HistoryResponse> {
        Request(
            path: "v1/archive/history2",
            method: .get,
            query: [
                ("access_point", parameters.accessPoint),
                ("begin_time", String(parameters.beginTimeMs)),
                ("end_time", String(parameters.endTimeMs)),
                ("max_count", String(parameters.maxCount)),
                ("min_gap_ms", String(parameters.minGapMs)),
                ("scan_mode", parameters.scanMode.rawValue),
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
    ) -> Request<CalendarResponse> {
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
    ) -> Request<CalendarResponse> {
        calendar(accessPoint: accessPoint, begin: begin, end: end)
    }

    /// Endpoint: `GET /v1/archive/size`
    ///
    /// Returns disk usage and playback duration for a time interval.
    public static func size(
        accessPoint: AccessPoint,
        beginTime: String,
        endTime: String
    ) -> Request<SizeResponse> {
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
    ) -> Request<RecInfoResponse> {
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
    ) -> Request<VolumesStateResponse> {
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
    
    /// Legacy method to get frames, from AxxonNextRoute.frames (old Client proj)
    /// Endpoint: `GET /archive/contents/frames/VIDEOSOURCEID/ENDTIME/BEGINTIME?limit=COUNT`
    ///
    /// Returns days that contain records for a source.
    /// Sample: http://try.axxonsoft.com/archive/contents/frames/OWNEROR-2LRQDEG/DeviceIpint.3/SourceEndpoint.video:0:0/future/past?limit=5
    public static func framesLegacy(
        accessPoint: AccessPoint,   //TODO: вот тут должен быть не accessPoint камеры, а accessPoint потока который пишется в архив с id = storageId
        begin: Date,
        end: Date,
        limit: Int,
        storageId: AccessPoint?
    ) -> Request<CalendarResponse> {
        var query: [(String, String?)] = [
            ("limit", String(limit))
        ]
        
        if let storageId {
            query.append(("archive", storageId.hosts))
        }
        
        return Request(
            path: "archive/contents/frames/\(accessPoint.nohosts)/\(end)/\(begin)",
            method: .get,
            query: query
        )
    }    
}
