import Foundation

public protocol HttpTransport {
    func setConfiguration(scheme: String, host: String, sharedHeaders: [String: String]?)
    func sendRequest(with params: HttpRequestParams) async throws -> HttpOperationResult
}
