# RetroSwift

This library provides the approach to API contract definition in the Retrofit-like fashion on Swift.

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

`ApiDomain` in the simplest case can be implemented as follow:

```swift
class ApiDomain: NetworkProviding {
    override init(networkService: NetworkService) {
        super.init(networkService: networkService)

        networkService.setConfiguration(
            scheme: "https",
            host: "rest.somedomain.com",
            sharedHeaders: ["Content-Type": "application/json"])
    }
}
```

More complex solutions can include, for example, session token management.

`NetworkService` is the protocol describing HTTP network communication layer. 

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

`DemoProject` contains simple implementation based on the UrlSession, but you can provide yours depending on your needs.

## Adding RetroSwift as a Dependency

### Xcode

If you're working with a project in Xcode RetroSwift can be easily integrated:
1. In Xcode, select `File > Add Packages...`
1. Or go to the project's settings, select your project from the list, go to the `Package Dependencies` and click `+` button
1. Specify the Repository: `https://github.com/level-two/RetroSwift`
1. Go to the Target, on `General` tab find `Frameworks, Libraries and Embedded content` section, click '+' and add RetroSwift library as a dependency 

### Swift Package Manager

To use this library in a SwiftPM project, add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/level-two/RetroSwift", from: "0.0.1"),
```

and include it as a dependency for your target:

```swift
.target(
    ...
    dependencies: [
        "RetroSwift",
    ],
    ...
),
```

Finally, add `import RetroSwift` to your source code.
