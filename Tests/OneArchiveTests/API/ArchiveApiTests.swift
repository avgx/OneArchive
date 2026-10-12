import Foundation
import RequestResponse
import Testing
@testable import OneArchive

@Suite("ArchiveApi request builders")
struct ArchiveApiTests {
    @Test("history2 builds query parameters")
    func history2_query() throws {
        let begin = ArchiveTime.epoch1900
        let end = ArchiveTime.date(millisecondsSince1900: 200)
        let parameters = HistoryRequest(
            accessPoint: "hosts/Demoserver/MultimediaStorage.AliceBlue/Sources/src.test",
            begin: begin,
            end: end,
            maxCount: 50,
            minGapMs: 60_000,
            scanMode: .exact
        )
        let request = ArchiveApi.history2(parameters)
        #expect(request.path == "v1/archive/history2")
        #expect(request.method == .get)
        #expect(request.query?.contains(where: { $0.0 == "scan_mode" && $0.1 == "SM_EXACT" }) == true)
        #expect(request.query?.contains(where: { $0.0 == "begin_time" && $0.1 == "0" }) == true)
        let endMs = try #require(request.query?.first(where: { $0.0 == "end_time" })?.1.flatMap(Int64.init))
        #expect(endMs == ArchiveTime.millisecondsSince1900(end))
    }

    @Test("typed Request response markers")
    func typed_request_markers() {
        let ap = "hosts/Demoserver/MultimediaStorage.AliceBlue/Sources/src.test"
        let begin = Date(timeIntervalSince1970: 1_700_000_000)
        let end = Date(timeIntervalSince1970: 1_800_000_000)

        let _: Request<HistoryResponse> = ArchiveApi.history2(
            HistoryRequest(
                accessPoint: ap,
                begin: begin,
                end: end,
                maxCount: 10,
                minGapMs: 0,
                scanMode: .exact
            )
        )
        let _: Request<CalendarResponse> = ArchiveApi.calendar(accessPoint: ap, begin: begin, end: end)
        let _: Request<CalendarResponse> = ArchiveApi.depth(accessPoint: ap, begin: begin, end: end)
        let _: Request<SizeResponse> = ArchiveApi.size(
            accessPoint: ap,
            beginTime: "20180604T000000.000000",
            endTime: "20180605T000000.000000"
        )
        let _: Request<RecInfoResponse> = ArchiveApi.recordingInfo(accessPoint: ap)
        let _: Request<VolumesStateResponse> = ArchiveApi.volumesState(
            accessPoint: "hosts/Demoserver/MultimediaStorage.AliceBlue/MultimediaStorage"
        )
        let _: Request<FramesResponse> = ArchiveApi.frames(
            accessPoint: "hosts/SERVER1/DeviceIpint.2/SourceEndpoint.video:0:0",
            end: .past,
            begin: .future,
            limit: 3
        )
        let _: Request<StatisticsDepthResponse> = ArchiveApi.statisticsDepth(
            accessPoint: "hosts/SERVER1/DeviceIpint.1/SourceEndpoint.video:0:0",
            archive: "hosts/SERVER1/MultimediaStorage.Red/MultimediaStorage",
            thresholdDays: 365
        )
        let _: Request<ContentsIntervalsResponse> = ArchiveApi.contentsIntervals(
            accessPoint: "hosts/SERVER1/DeviceIpint.1/SourceEndpoint.video:0:0",
            end: .future,
            begin: .past,
            limit: 1,
            scale: 1_000_000_000,
            archive: "hosts/SERVER1/MultimediaStorage.Red/MultimediaStorage"
        )
    }

    @Test("frames builds path and query")
    func frames_path_and_query() {
        let cursor = Date(timeIntervalSince1970: 1_700_000_000)
        let request = ArchiveApi.frames(
            accessPoint: "hosts/SERVER1/DeviceIpint.2/SourceEndpoint.video:0:0",
            end: .past,
            begin: .instant(cursor),
            limit: 5,
            archive: "hosts/SERVER1/MultimediaStorage.AliceBlue/MultimediaStorage"
        )
        #expect(
            request.path
                == "archive/contents/frames/SERVER1/DeviceIpint.2/SourceEndpoint.video:0:0/past/\(ArchiveTimeBound.instant(cursor).pathSegment)"
        )
        #expect(request.method == .get)
        #expect(request.query?.contains(where: { $0.0 == "limit" && $0.1 == "5" }) == true)
        #expect(
            request.query?.contains(where: {
                $0.0 == "archive" && $0.1 == "hosts/SERVER1/MultimediaStorage.AliceBlue/MultimediaStorage"
            }) == true
        )
    }

    @Test("depth matches calendar request")
    func depth_matches_calendar() {
        let begin = Date(timeIntervalSince1970: 1_700_000_000)
        let end = Date(timeIntervalSince1970: 1_800_000_000)
        let ap = "hosts/Demoserver/MultimediaStorage.AliceBlue/Sources/src.test"
        let depth = ArchiveApi.depth(accessPoint: ap, begin: begin, end: end)
        let calendar = ArchiveApi.calendar(accessPoint: ap, begin: begin, end: end)
        #expect(depth.path == calendar.path)
        #expect(depth.query?.map(\.0) == calendar.query?.map(\.0))
        #expect(depth.query?.map(\.1) == calendar.query?.map(\.1))
    }

    @Test("statisticsDepth builds video path and threshold")
    func statisticsDepth_path_and_query() {
        let request = ArchiveApi.statisticsDepth(
            accessPoint: "hosts/SERVER1/DeviceIpint.1/SourceEndpoint.video:0:0",
            archive: "SERVER1/MultimediaStorage.Red/MultimediaStorage",
            thresholdDays: 365
        )
        #expect(request.method == .get)
        #expect(
            request.path
                == "archive/statistics/depth/SERVER1/DeviceIpint.1/SourceEndpoint.video:0:0"
        )
        #expect(
            request.query?.contains(where: {
                $0.0 == "archive" && $0.1 == "hosts/SERVER1/MultimediaStorage.Red/MultimediaStorage"
            }) == true
        )
        #expect(request.query?.contains(where: { $0.0 == "threshold" && $0.1 == "365" }) == true)
    }

    @Test("statisticsDepth omits threshold when unset")
    func statisticsDepth_omits_threshold() {
        let request = ArchiveApi.statisticsDepth(
            accessPoint: "hosts/SERVER1/DeviceIpint.1/SourceEndpoint.video:0:0"
        )
        #expect(request.query == nil)
    }

    @Test("contentsIntervals builds future/past path and query")
    func contentsIntervals_future_past() {
        let request = ArchiveApi.contentsIntervals(
            accessPoint: "hosts/SERVER1/DeviceIpint.1/SourceEndpoint.video:0:0",
            end: .future,
            begin: .past,
            limit: 1,
            scale: 1_000_000_000,
            archive: "hosts/SERVER1/MultimediaStorage.Red/MultimediaStorage"
        )
        #expect(request.method == .get)
        #expect(
            request.path
                == "archive/contents/intervals/SERVER1/DeviceIpint.1/SourceEndpoint.video:0:0/future/past"
        )
        #expect(request.query?.contains(where: { $0.0 == "limit" && $0.1 == "1" }) == true)
        #expect(request.query?.contains(where: { $0.0 == "scale" && $0.1 == "1000000000" }) == true)
        #expect(request.query?.contains(where: { $0.0 == "offset" }) == false)
        #expect(
            request.query?.contains(where: {
                $0.0 == "archive" && $0.1 == "hosts/SERVER1/MultimediaStorage.Red/MultimediaStorage"
            }) == true
        )
    }

    @Test("contentsIntervals builds instant bounds and offset")
    func contentsIntervals_instants_and_offset() {
        let begin = Date(timeIntervalSince1970: 1_700_000_000)
        let end = Date(timeIntervalSince1970: 1_800_000_000)
        let request = ArchiveApi.contentsIntervals(
            accessPoint: "hosts/SERVER1/DeviceIpint.1/SourceEndpoint.video:0:0",
            end: .instant(end),
            begin: .instant(begin),
            limit: 500,
            scale: 1,
            offset: 20,
            archive: "hosts/SERVER1/MultimediaStorage.Red/MultimediaStorage"
        )
        #expect(
            request.path
                == "archive/contents/intervals/SERVER1/DeviceIpint.1/SourceEndpoint.video:0:0/\(ArchiveTimeBound.instant(end).pathSegment)/\(ArchiveTimeBound.instant(begin).pathSegment)"
        )
        #expect(request.query?.contains(where: { $0.0 == "limit" && $0.1 == "500" }) == true)
        #expect(request.query?.contains(where: { $0.0 == "scale" && $0.1 == "1" }) == true)
        #expect(request.query?.contains(where: { $0.0 == "offset" && $0.1 == "20" }) == true)
    }

    @Test("volumesState repeats volume_ids")
    func volumes_state_volume_ids() {
        let request = ArchiveApi.volumesState(
            accessPoint: "hosts/Demoserver/MultimediaStorage.AliceBlue/MultimediaStorage",
            volumeIds: ["vol-a", "vol-b"]
        )
        let ids = request.query?.filter { $0.0 == "volume_ids" }.compactMap(\.1) ?? []
        #expect(ids == ["vol-a", "vol-b"])
    }
}
