import Foundation
import OneWireFormat
import RequestResponse

/// Archive API (Native BL `v1/archive/*`).
public enum ArchiveApi {
    /// Endpoint: `GET /v1/archive/history2`
    ///
    /// Returns available history intervals for a source. Response may be partial; see `HistoryResponse.result`.
    public static func history2(_ parameters: HistoryRequest) -> Request<HistoryResponse> {
        precondition(parameters.accessPoint.contains("/Sources/src."))
        return Request(
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
        precondition(accessPoint.contains("/Sources/src."))
        return Request(
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
        precondition(accessPoint.contains("/Sources/src."))
        return calendar(accessPoint: accessPoint, begin: begin, end: end)
    }

    /// Endpoint: `GET /v1/archive/size`
    ///
    /// Returns disk usage and playback duration for a time interval.
    public static func size(
        accessPoint: AccessPoint,
        beginTime: String,
        endTime: String
    ) -> Request<SizeResponse> {
        precondition(accessPoint.contains("/Sources/src."))
        return Request(
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
        precondition(accessPoint.contains("/Sources/src."))
        return Request(
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
        precondition(accessPoint.contains("MultimediaStorage"))
        precondition(!accessPoint.contains("/Sources/src."))
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
    
    /// Endpoint: `GET /archive/contents/frames/{VIDEOSOURCEID}/{ENDTIME}/{BEGINTIME}`
    ///
    /// Returns registration times of frames stored in the archive for the video stream endpoint.
    /// Use ``ArchiveTimeBound/past`` / ``ArchiveTimeBound/future`` or an instant for unbounded ranges.
    ///
    /// Sample: `archive/contents/frames/SERVER1/DeviceIpint.2/SourceEndpoint.video:0:0/past/future?limit=3`
    public static func frames(
        accessPoint: AccessPoint,
        end: ArchiveTimeBound,
        begin: ArchiveTimeBound,
        limit: Int = 250,
        archive: AccessPoint? = nil
    ) -> Request<FramesResponse> {
        precondition(accessPoint.contains("SourceEndpoint.video"))
        precondition(!accessPoint.contains("/Sources/src."))
        var query: [(String, String?)] = [
            ("limit", String(limit)),
        ]

        if let archive {
            precondition(archive.contains("MultimediaStorage"))
            precondition(!archive.contains("/Sources/src."))
            query.append(("archive", archive.hosts))
        }

        return Request(
            path: "archive/contents/frames/\(accessPoint.nohosts)/\(end.pathSegment)/\(begin.pathSegment)",
            method: .get,
            query: query
        )
    }

    /// Endpoint: `GET /archive/statistics/depth/{VIDEOSOURCEID}`
    ///
    /// Legacy archive bounds for a video stream. `thresholdDays` is the gap, in days, that still
    /// counts as one continuous recording. The server default is 1, which stops at the latest
    /// continuous piece when older records are separated by a longer gap.
    ///
    /// `accessPoint` is the video source (`SourceEndpoint.video`), not a storage source.
    public static func statisticsDepth(
        accessPoint: AccessPoint,
        archive: AccessPoint? = nil,
        thresholdDays: Int? = nil
    ) -> Request<StatisticsDepthResponse> {
        precondition(accessPoint.contains("SourceEndpoint.video"))
        precondition(!accessPoint.contains("/Sources/src."))
        var query: [(String, String?)] = []
        if let archive {
            precondition(archive.contains("MultimediaStorage"))
            precondition(!archive.contains("/Sources/src."))
            query.append(("archive", archive.hosts))
        }
        if let thresholdDays {
            query.append(("threshold", String(thresholdDays)))
        }
        return Request(
            path: "archive/statistics/depth/\(accessPoint.nohosts)",
            method: .get,
            query: query.isEmpty ? nil : query
        )
    }

    /// Endpoint: `GET /archive/contents/intervals/{VIDEOSOURCEID}/{ENDTIME}/{BEGINTIME}`
    ///
    /// Legacy recorded intervals for a video stream. Path order is end, then begin.
    /// Use ``ArchiveTimeBound/past`` / ``ArchiveTimeBound/future`` or an instant.
    ///
    /// `accessPoint` is the video source (`SourceEndpoint.video`), not a storage source.
    /// `scale` is the interval resolution in seconds; larger values merge neighboring records.
    public static func contentsIntervals(
        accessPoint: AccessPoint,
        end: ArchiveTimeBound,
        begin: ArchiveTimeBound,
        limit: Int,
        scale: Int64,
        offset: Int? = nil,
        archive: AccessPoint
    ) -> Request<ContentsIntervalsResponse> {
        precondition(accessPoint.contains("SourceEndpoint.video"))
        precondition(!accessPoint.contains("/Sources/src."))
        precondition(archive.contains("MultimediaStorage"))
        precondition(!archive.contains("/Sources/src."))
        var query: [(String, String?)] = [
            ("limit", String(limit)),
            ("scale", String(scale)),
            ("archive", archive.hosts),
        ]
        if let offset {
            query.append(("offset", String(offset)))
        }
        return Request(
            path: "archive/contents/intervals/\(accessPoint.nohosts)/\(end.pathSegment)/\(begin.pathSegment)",
            method: .get,
            query: query
        )
    }
}
