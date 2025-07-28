import RetroSwift
import Foundation

final class UrlSessionTransport: HttpTransport {
    func setConfiguration(scheme: String, host: String, sharedHeaders: [String: String]?) {
        self.scheme = scheme
        self.host = host
        self.sharedHeaders = sharedHeaders
    }

    func sendRequest(with params: HttpRequestParams) async throws -> HttpOperationResult {
        do {
            let urlRequest = try assembleURLRequest(params: params)

            return await self.perform(request: urlRequest)
        } catch {
            return HttpOperationResult(
                statusCode: nil,
                headers: nil,
                response: .failure(error)
            )
        }
    }

    private var scheme: String?
    private var host: String?
    private var sharedHeaders: [String: String]?

    private lazy var urlSession = URLSession(
        configuration: {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 300
            configuration.httpAdditionalHeaders = sharedHeaders
            return configuration
        }()
    )
}

private extension UrlSessionTransport {
    func assembleURLRequest(params: HttpRequestParams) throws -> URLRequest {
        var urlComponents = URLComponents()

        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = params.path
        urlComponents.queryItems = params.queryParams?.map(URLQueryItem.init)

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = params.httpMethod.asString

        params.headerParams?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        sharedHeaders?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if params.formParams != nil || params.formFiles != nil {
            let (body, contentType) = makeMultipartBody(
                params: params.formParams ?? [],
                files: params.formFiles ?? []
            )
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body
        } else {
            urlRequest.httpBody = params.body
        }

        return urlRequest
    }

    /// Builds the body `Data` and corresponding `Content‑Type` header value.
    func makeMultipartBody(
        params: [HttpRequestParams.FormParam],
        files: [HttpRequestParams.FormFile]
    ) -> (body: Data, contentType: String) {

        let boundary = "Boundary-\(UUID().uuidString)"
        let lineBreak = "\r\n"
        var body = Data()

        for param in params {
            let bodyPart =
                "--\(boundary)\(lineBreak)" +
                "Content-Disposition: form-data; name=\"\(param.name)\"\(lineBreak)\(lineBreak)" +
                "\(param.content)\(lineBreak)"

            body.append(bodyPart.data(using: .utf8)!)
        }

        for file in files {
            let bodyPart =
                "--\(boundary)\(lineBreak)" +
                "Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\(lineBreak)" +
                "Content-Type: \(file.mimeType)\(lineBreak)\(lineBreak)"

            body.append(bodyPart.data(using: .utf8)!)
            body.append(file.content)
            body.append(lineBreak.data(using: .utf8)!)
        }

        body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
        return (body, "multipart/form-data; boundary=\(boundary)")
    }
}

private extension UrlSessionTransport {
    func perform(request: URLRequest) async -> HttpOperationResult {
        await withCheckedContinuation { [weak self] continuation in
            self?.dataTask(request: request, continuation: continuation)
                .resume()
        }
    }

    func dataTask(
        request: URLRequest,
        continuation: CheckedContinuation<HttpOperationResult, Never>
    ) -> URLSessionDataTask {

        print(request.customDescription)

        return urlSession.dataTask(with: request) { data, response, error in
            print(Self.responseDescription(forData: data, response: response, error: error))

            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode

            var headers: [String: String]?

            if let allHeaderFields = httpResponse?.allHeaderFields {
                headers = .init(minimumCapacity: allHeaderFields.count)
                allHeaderFields.forEach {
                    let key = String(describing: $0.key)
                    let value = String(describing: $0.value)
                    headers?[key] = value
                }
            }

            let operationResult = HttpOperationResult(
                statusCode: statusCode,
                headers: headers,
                response: error != nil ?
                    .failure(error!) :
                        .success(data ?? Data())
            )

            continuation.resume(returning: operationResult)
        }
    }
}

private extension HttpMethod {
    var asString: String {
        switch self {
        case .delete: return "DELETE"
        case .get: return "GET"
        case .head: return "HEAD"
        case .patch: return "PATCH"
        case .post: return "POST"
        case .put: return "PUT"
        }
    }
}

private extension UrlSessionTransport {
    static func responseDescription(forData data: Data?, response: URLResponse?, error: Error?) -> String {
        var description = [] as [String]

        description.append("Response:")
        description.append(response?.description ?? "")

        if let error {
            description.append("Error:")
            description.append(error.localizedDescription)
        } else {
            description.append("Body:")
            description.append(String(data: data ?? Data(), encoding: .utf8) ?? "Empty")
        }

        return description.joined(separator: "\n")
    }
}

private extension URLRequest {
    var customDescription: String {
        var description = [] as [String]

        description.append("Request:")

        if let httpMethod {
            description.append("Method: \(httpMethod)")
        }

        if let url {
            description.append("URL: \(url)")
        }

        if let allHTTPHeaderFields, !allHTTPHeaderFields.isEmpty {
            description.append("Headers: \(allHTTPHeaderFields)")
        }

        if let httpBody, let bodyDescription = String(data: httpBody, encoding: .utf8) {
            description.append("Body: \(bodyDescription)")
        }

        return description.joined(separator: "\n")
    }
}
