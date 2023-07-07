import RetroSwift
import Foundation

struct ArtistEventsRequest {
    @Path("artist_name") var artistName: String = ""
    @Query("app_id") var appId: String = ""
    @Query var date: String
}
