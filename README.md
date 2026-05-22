# OneArchive

Swift package with **hand-written `Codable` models** and **typed HTTP request builders** for the Native BL **Archive** API (`v1/archive/*`), aligned with [`ArchiveSupport.proto`](https://github.com/jerrygergov/axxon-telegram-vms/blob/main/support/protos/axxonsoft/bl/archive/ArchiveSupport.proto) and validated against **real server JSON**.

The package does **not** use protobuf code generation. Models follow what the server actually returns (including numeric fields sent as strings).

**Platforms:** iOS 15+, macOS 13+, tvOS 17+, visionOS 1+  
**Swift tools:** 6.1+

## Dependencies

| Package | Role in OneArchive |
|---------|-------------------|
| [RequestResponse](https://github.com/avgx/RequestResponse) | `ArchiveApi` returns `Request<Response>`; paths are relative to a `RequestBuilder` base URL |
| [SafeEnum](https://github.com/avgx/SafeEnum) | Unknown enum wire values decode without failing the payload (e.g. `result`, volume `state`) |

## What is included

### API surface (`ArchiveApi`)

| Method | HTTP | `Request<…>` |
|--------|------|--------------|
| `ArchiveApi.history2(_:)` | `GET /v1/archive/history2` | `HistoryResponse` |
| `ArchiveApi.calendar(accessPoint:begin:end:)` | `GET /v1/archive/calendar` | `CalendarResponse` |
| `ArchiveApi.depth(accessPoint:begin:end:)` | `GET /v1/archive/calendar` (wide range) | `CalendarResponse` → ``CalendarResponse/depth`` |
| `ArchiveApi.size(accessPoint:beginTime:endTime:)` | `GET /v1/archive/size` | `SizeResponse` |
| `ArchiveApi.recordingInfo(accessPoint:updateCache:)` | `GET /v1/archive/recordingInfo` | `RecInfoResponse` |
| `ArchiveApi.volumesState(accessPoint:volumeIds:)` | `GET /v1/archive/volumes/state` | `VolumesStateResponse` |

Unlike **OneDomain** (`Request<Data>` + SSE/multipart), archive endpoints return a single JSON document — the response type is known at the call site.


### Access point

Use a **storage source** access point (`hosts/…/Sources/src.…` from archive bindings), not the camera video endpoint, for `history2` and `calendar`. For `recordingInfo` and `volumes/state`, use the **storage** access point (`hosts/…/MultimediaStorage.…`).

```swift
public typealias AccessPoint = String  // JSON key: access_point
```

## Usage

```swift
import OneArchive
import RequestResponse

let sourceAP = "hosts/Demoserver/MultimediaStorage.AliceBlue/Sources/src.4CA1C29C-1701-20D0-3314-2616196C6730"

let begin = ArchiveTime.date(millisecondsSince1900: 3_961_369_121_412)
let end = begin.addingTimeInterval(3600)

let parameters = HistoryRequest(
    accessPoint: sourceAP,
    begin: begin,
    end: end,
    maxCount: 500,
    minGapMs: 0,
    scanMode: .exact
)
let history: Request<HistoryResponse> = ArchiveApi.history2(parameters)

// Archive depth (legacy `statistics/depth` replacement)
let depth: Request<CalendarResponse> = ArchiveApi.depth(
    accessPoint: sourceAP,
    begin: ArchiveTime.epoch1900,
    end: .now
)

// Send with Get / RequestBuilder → Response<HistoryResponse>.value
// history.intervals[0].begin / .end are `Date`
// calendar.depth is `ArchiveDepth?`
```

## Timeline policy (replacing legacy archive intervals)

Legacy clients used `archive/contents/intervals` with `scale` and `archive/statistics/depth`. With v1 APIs the app should orchestrate:

### Archive depth (outer bounds)

Pick one:

1. **`ArchiveApi.depth`** / **`calendar`** on a wide range (years) → ``CalendarResponse/depth`` (`ArchiveDepth`) from recorded days.
2. **`history2`** on a wide range with large `min_gap_ms` and `scan_mode: SM_APPROXIMATE` → merge `intervals` into an outer span (similar to `outerInterval` on legacy intervals).

`calendar` is simpler for “which days have data”; wide `history2` is better when you need continuous merged intervals.

### Zoom levels

| UI level | API | Parameters |
|----------|-----|------------|
| Days / months | `calendar` or `history2` | wide range; history2: large `min_gap_ms` (day+), `SM_APPROXIMATE` |
| Hours | `history2` | `min_gap_ms` ~ 3_600_000 (1 h) |
| Minutes | `history2` | `min_gap_ms` ~ 60_000 (1 min) |
| **Finest** (seconds) | `history2` | **`SM_EXACT`**, small `min_gap_ms` (0), **`end_time - begin_time ≤ 1 hour`** |

For fine zoom on ranges longer than one hour, split into 1-hour chunks with `SM_EXACT`, or use `SM_APPROXIMATE` / larger `min_gap_ms`.

### Partial responses

Handle in the app (not in this package):

- `result == PARTIAL` — narrow range or reduce window; continue from last `interval.end`.
- `result == TRY_LATER` — retry after a delay.

## Module layout

```
Sources/OneArchive/
├── API/           ArchiveApi, AccessPoint
├── History/       HistoryRequest, HistoryResponse, ScanMode, …
├── Calendar/      CalendarResponse, ArchiveDepth
├── Size/          SizeResponse
├── RecordingInfo/
├── Volumes/       VolumesStateResponse, VolumeState
└── Primitive/     ArchiveTime, ArchiveWireInt64 (string or number on wire)
```

Tests mirror folders under `Tests/OneArchiveTests/Decoding/`. Fixtures in `Tests/OneArchiveTests/Resources/` (`v1_archive_*.json`).

## Wire quirks

| Field | Server behavior |
|-------|-----------------|
| `intervals[].begin_time`, `end_time` | Often JSON **strings** |
| `days[]` | Often JSON **strings** |
| `recording_info.*`, `size`, `duration`, volume bytes | Often JSON **strings** |

`ArchiveWireInt64` / `ArchiveWireUInt64` decode numeric or string scalars; ``ArchiveTime`` converts the 1900-01-01 UTC epoch to `Date` in public models.

## Tests

```bash
swift test
```

Deterministic decoding tests on bundled fixtures; no live integration tests in CI.

### Capturing fixtures

```bash
SRC='hosts/Demoserver/MultimediaStorage.AliceBlue/Sources/src.4CA1C29C-1701-20D0-3314-2616196C6730'
STORAGE='hosts/Demoserver/MultimediaStorage.AliceBlue/MultimediaStorage'

curl -s 'http://try.axxonsoft.com/v1/archive/history2' -u 'root:Root1234' \
  --get --data-urlencode "access_point=${SRC}" \
  --data-urlencode 'begin_time=3721920000000' \
  --data-urlencode 'end_time=3980000000000' \
  --data-urlencode 'max_count=5' \
  --data-urlencode 'min_gap_ms=86400000' \
  --data-urlencode 'scan_mode=SM_APPROXIMATE'

curl -s 'http://try.axxonsoft.com/v1/archive/calendar' -u 'root:Root1234' \
  --get --data-urlencode "access_point=${SRC}" \
  --data-urlencode 'begin_time=3721920000000' \
  --data-urlencode 'end_time=3980000000000'

curl -s 'http://try.axxonsoft.com/v1/archive/recordingInfo' -u 'root:Root1234' \
  --get --data-urlencode "access_point=${STORAGE}"

curl -s 'http://try.axxonsoft.com/v1/archive/volumes/state' -u 'root:Root1234' \
  --get --data-urlencode "access_point=${STORAGE}"
```

## Related work

- **OneDomain** — cameras, archive bindings; uses `Request<Data>` for streaming list APIs.
- **Get** + **RequestResponse** — `RequestBuilder.json` sends typed `Request<T>`; client decodes `Response<T>`.

## License

See [LICENSE](LICENSE).
