# RetroSwift Demo project

This project demonstrates the way of API contract definition in the Retrofit-like fashion on Swift.

It gives us possibility to define API in this way:

```swift
final class BandsInTownApi: BandsInTownDomain {
    @Get("/artists/{artist_name}")
    var findArtist: (FindArtistRequest) async throws -> FindArtistResponse

    @Get("/artists/{artist_name}")
    var testEmptyResponse: (FindArtistRequest) async throws -> Empty

    @Get("/artists/{artist_name}/events")
    var artistEvents: (ArtistEventsRequest) async throws -> Either<ArtistEventsResponse, ArtistEventsErrorResponse>
}
```

Additionally to these definitions *Request types provide more details on contract with the endpoints, namely on particular data fields and their matching to the HTTP params - query, header, path, body:

```swift
struct FindArtistRequest {
    @Path("artist_name") var artistName: String = ""
    @Query("app_id") var appId: String = ""
}

struct ArtistEventsRequest {
    @Path("artist_name") var artistName: String = ""
    @Query("app_id") var appId: String = ""
    @Query var date: String
}
```

View model interacts with the API. Yes, it's bad practice, but remember - this is just demo project.
First it initializes API providing transport layer. UrlSessionTransport implements actual communication through the network

```swift
let api = BandsInTownApi(transport: UrlSessionTransport())
```

Usual request:
```swift
let findArtistRequest = FindArtistRequest(artistName: artist, appId: "123")
let artistDetails = try await api.findArtist(findArtistRequest)
```

Dropping response data:
```swift
let findArtistRequest = FindArtistRequest(artistName: artist, appId: "123")
_ = try await api.testEmptyResponse(findArtistRequest)
```

Response contains decoded data for either successfull response or error one 
```swift
let eventsRequest = ArtistEventsRequest(artistName: artist, appId: "123", date: "2023-05-05,2023-09-05")
let eventsResponse = try await api.artistEvents(eventsRequest)
```
