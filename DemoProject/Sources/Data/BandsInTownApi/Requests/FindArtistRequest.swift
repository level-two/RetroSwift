import RetroSwift

struct FindArtistRequest {
    @Path("artist_name") var artistName: String = ""
    @Query("app_id") var appId: String = ""
}
