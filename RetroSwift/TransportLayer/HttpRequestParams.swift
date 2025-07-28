import Foundation

public struct HttpRequestParams {
    public let httpMethod: HttpMethod
    public let path: String
    public let headerParams: [String: String]?
    public let queryParams: [String: String]?
    public let formParams: [FormParam]?
    public let formFiles: [FormFile]?
    public let body: Data?

    public struct FormParam {
        let name: String
        let content: String
    }

    public struct FormFile {
        let name: String
        let fileName: String
        let mimeType: String
        let content: Data
    }
}
