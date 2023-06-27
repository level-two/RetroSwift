import Foundation

struct ArtistEventsErrorResponse: Error, Decodable {
    let errorMessage: String

    enum CodingKeys: String, CodingKey {
        case errorMessage = "Message"
    }
}
