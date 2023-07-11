import RetroSwift

final class BandsInTownApi: BandsInTownDomain {
    @Get("/artists/{artist_name}")
    var findArtist: (FindArtistRequest) async throws -> FindArtistResponse

    @Get("/artists/{artist_name}/events")
    var artistEvents: (ArtistEventsRequest) async throws
        -> Either<ArtistEventsResponse, ArtistEventsErrorResponse>
}
