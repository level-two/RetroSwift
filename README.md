# RetroSwift

This library provides the approach to API contract definition in the Retrofit-like fashion on Swift.

It gives possibility to define API in this way:

```swift
final class SchedulesApi: ApiDomain {
    @Get("/api/v1/schedule")
    var getSchedules: (GetSchedulesRequest) async throws -> GetSchedulesResponse

    @Put("/api/v1/schedule")
    var createSchedule: (CreateScheduleRequest) async throws -> Empty

    @Post("/api/v1/schedule/{schedule_id}")
    var updateSchedule: (UpdateScheduleRequest) async throws -> UpdateScheduleResponse

    @Delete("/api/v1/schedule/{schedule_id}")
    var deleteSchedule: (DeleteScheduleRequest) async throws -> Either<DeleteScheduleResponse, DeleteScheduleErrorResponse>
}
```

`*Request` types provide more details on endpoints contracts, namely define parameters and their mapping to the HTTP params - `Query`, `Header`, `Path`, `JsonBody`, `FormParam`, `FormFile`:

```swift
struct GetSchedulesRequest {
    @Query var page: Int
    @Query("limit") var schedulesPerPage: Int = 0
    @Header("X-Account-Id") var accountId: String = ""
}

struct CreateScheduleRequest {
    @Header("X-Account-Id") var accountId: String = ""
    @JsonBody var scheduleBody: Schedule
}

struct DeleteScheduleRequest {
    @Path("schedule_id") var ScheduleId: String = ""
    @Header("X-Account-Id") var accountId: String = ""
}

struct SpeechToTextApiRequest {
    @FormParam("model_id") var modelId = ""
    @FormParam("language_code") var languageCode = ""
    @FormParam("tag_audio_events") var tagAudioEvents = false
    @FormParam("num_speakers") var numSpeakers = 1
    @FormFile("file") var recording = .empty
}
```

Usage is quite simple:

```swift
let transport: HttpTransport = ....
let api = SchedulesApi(transport: transport)

let request = GetSchedulesRequest(page: 1, schedulesPerPage: 30, accountId: "acc_id")
let response = try await api.getSchedules(request)
```

Sending multipart form:

```swift
let request = ElevenLabsApi.SpeechToTextApiRequest(
    modelId: "scribe_v1",
    languageCode: languageCode,
    tagAudioEvents: false,
    numSpeakers: 1,
    recording: .init(fileName: "recording.caf", mimeType: "audio/x-caf", content: recording)
)

let transcribedText = try await api.speechToText(request).text
```

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
class ApiDomain: Domain {
    override init(transport: HttpTransport) {
        super.init(transport: transport)
        transport.setConfiguration(scheme: "https", host: "rest.bandsintown.com", sharedHeaders: nil)
    }
}
```

More complex solutions can include, for example, session token management.

`HttpTransport` is the protocol describing HTTP network communication layer. 

```swift
public protocol HttpTransport {
    func setConfiguration(scheme: String, host: String, sharedHeaders: [String: String]?)
    func sendRequest(with params: HttpRequestParams) async throws -> HttpOperationResult
}
```

`DemoProject` contains simple implementation based on the UrlSession, but you can provide yours depending on your needs.

## Features

Supported HTTP methods:
* `@Delete`
* `@Get`
* `@Head`
* `@Patch`
* `@Post`
* `@Put`

Supported parameter types:
* `@Header`
* `@Path`
* `@Query`
* `@JsonBody`
* `@FormParam`
* `@FormFile`

By default parameter name is derived from the variable name, but it can be customized:

```swift
@Header("X-Account-Id") var accountId: String = ""
``` 

Supported response types:
* any type conforming to `Decodable`
* `Either<Response: Decodable, ErrorResponse: Decodable>`
* `Empty`

`Either` type allows to get either success or error response.

Response mocking. You can easily mock response by assigning directly to the api's endpoint definition:

```swift
api.deleteSchedule = { _ in
    .errorResponse(DeleteScheduleErrorResponse(errorMessage: "Schedule not found"))
}
```

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
