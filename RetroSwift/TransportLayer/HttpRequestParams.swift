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
        public let name: String
        public let content: String
    }

    public struct FormFile {
        public let name: String
        public let fileName: String
        public let mimeType: String
        public let content: Data
    }
}
