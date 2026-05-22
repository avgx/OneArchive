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
        let _: Request<VolumesStateResponse> = ArchiveApi.volumesState(accessPoint: ap)
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
