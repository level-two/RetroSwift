# RetroSwift

This project demonstrates the way of API contract definition in the Retrofit-like fashion on Swift.

It gives us possibility to define API in this way:

```swift
final class SchedulesApi: ApiDomain {
    @Get("/api/v1/schedule")
    var getSchedules: (GetSchedulesRequest) async throws -> GetSchedulesResponse

    @Post("/api/v1/schedule")
    var createSchedule: (CreateScheduleRequest) async throws -> CreateScheduleResponse

    @Delete("/api/v1/schedule/{schedule_id}")
    var deleteSchedule: (DeleteScheduleRequest) async throws -> DeleteScheduleResponse
}
```

Additionally to these definitions *Request types provide more details on contract with the endpoints, namely on particular data fields and their matching to the HTTP params - query, header, path, body:

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

Additionally responses can be mocked in a straightforward and self-describing way:

```swift
api.getSchedules = { _ in
    GetSchedulesResponse(....)
}

api.deleteSchedule = { _ in
    throw URLError(.userAuthenticationRequired)
}
```

And the last thing. ApiDomain in the simplest case can be implemented as follow:

```swift
final class BandsInTownDomain: NetworkProviding {
    required init(networkService: NetworkService) {
        self.networkService = networkService

        networkService.setConfiguration(
            scheme: "https",
            host: "rest.bandsintown.com",
            sharedHeaders: ["Content-Type": "application/json"])
    }

    func perform<Request, Response: Decodable>(
        request: Request,
        to endpoint: EndpointDescribing
    ) async throws -> Response {

        try await networkService
            .request(
                httpMethod: endpoint.method.asString,
                path: resolvePath(format: endpoint.path, params: request),
                headerParams: getHeaderParams(from: request),
                queryParams: getQueryParams(from: request),
                body: getBody(from: request))
    }

    private let networkService: NetworkService
}
```

where NetworkService is something implementing HTTP communication through the network:

```swift
protocol NetworkService {
    func setConfiguration(
        scheme: String,
        host: String,
        sharedHeaders: [String: String]
    )

    func request<Response: Decodable>(
        httpMethod: String,
        path: String,
        headerParams: [String: String]?,
        queryParams: [String: String]?,
        body: Encodable?
    ) async throws -> Response
}
```
