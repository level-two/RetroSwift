# RetroSwift

This framework provides the approach to API contract definition in the Retrofit-like fashion on Swift.

It gives possibility to define API in this way:

```swift
final class SchedulesApi: ApiDomain {
    @Get("/api/v1/schedule")
    var getSchedules: (GetSchedulesRequest) async throws -> GetSchedulesResponse

    @Post("/api/v1/schedule")
    var createSchedule: (CreateScheduleRequest) async throws -> CreateScheduleResponse

    @Delete("/api/v1/schedule/{schedule_id}")
    var deleteSchedule: (DeleteScheduleRequest) async throws -> Either<DeleteScheduleResponse, DeleteScheduleErrorResponse>
}
```

Furthermore *Request types provide more details on contract with the endpoints, namely on particular data fields and their matching to the HTTP params - query, header, path, body:

```swift
struct GetSchedulesRequest {
    @Query var page: Int
    @Query("limit") var schedulesPerPage: Int = 0
    @Header("X-Account-Id") var accountId: String = ""
}

struct CreateScheduleRequest {
    @Header("X-Account-Id") var accountId: String = ""
    @Body var scheduleBody: Schedule
}

struct DeleteScheduleRequest {
    @Path("schedule_id") var ScheduleId: String = ""
    @Header("X-Account-Id") var accountId: String = ""
}
```

Usage is quite simple:

```swift
let api = SchedulesApi()
let request = GetSchedulesRequest(page: 1, schedulesPerPage: 30, accountId: "acc_id")
let response = try await api.getSchedules(request)
```

It is also possible to get decoded error response in case of unsuccess responses (status code is out of 200...299) and non-empty response body. It can be achieved by marking expected response type as `Either<DeleteScheduleResponse, DeleteScheduleErrorResponse>`

Additionally responses can be mocked in a straightforward and self-describing way:

```swift
api.getSchedules = { _ in
    GetSchedulesResponse(....)
}

api.deleteSchedule = { _ in
    throw URLError(.userAuthenticationRequired)
}

api.deleteSchedule = { _ in
    .errorResponse(DeleteScheduleErrorResponse(errorMessage: "Schedule not found"))
}

```

And the last thing. ApiDomain in the simplest case can be implemented as follow:

```swift
class ApiDomain: NetworkProviding {
    required init(networkService: NetworkService) {
        self.networkService = networkService

        networkService.setConfiguration(
            scheme: "https",
            host: "rest.bandsintown.com",
            sharedHeaders: ["Content-Type": "application/json"])
    }

    let networkService: NetworkService
}
```

where NetworkService is layer providing HTTP communication through the network:

```swift
public protocol NetworkService {
    func setConfiguration(
        scheme: String,
        host: String,
        sharedHeaders: [String: String]
    )

    func request(
        httpMethod: HttpMethod,
        path: String,
        headerParams: [String: String]?,
        queryParams: [String: String]?,
        body: Encodable?
    ) async throws -> NetworkOperationResult
}
```
