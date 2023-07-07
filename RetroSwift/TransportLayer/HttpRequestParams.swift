import Foundation

public struct HttpRequestParams {
    public let httpMethod: HttpMethod
    public let path: String
    public let headerParams: [String: String]?
    public let queryParams: [String: String]?
    public let body: Data?
}
