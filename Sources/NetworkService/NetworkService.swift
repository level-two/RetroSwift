import Foundation

public protocol NetworkService {
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
