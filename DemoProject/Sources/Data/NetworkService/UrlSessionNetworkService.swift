import RetroSwift
import Foundation

final class UrlSessionNetworkService: NetworkService {
    func setConfiguration(
        scheme: String,
        host: String,
        sharedHeaders: [String: String]
    ) {
        self.scheme = scheme
        self.host = host
        self.sharedHeaders = sharedHeaders
    }

    func request(
        httpMethod: HttpMethod,
        path: String,
        headerParams: [String: String]?,
        queryParams: [String: String]?,
        body: Encodable?
    ) async -> NetworkOperationResult {
        do {
            let urlRequest = try assembleURLRequest(
                httpMethod: httpMethod.asString,
                path: path,
                headerParams: headerParams,
                queryParams: queryParams,
                body: body)

            return await self.perform(request: urlRequest)
        } catch {
            return NetworkOperationResult(
                statusCode: 0,
                result: .failure(error)
            )
        }
    }

    private var scheme: String?
    private var host: String?
    private var sharedHeaders: [String: String]?

    private lazy var urlSession = URLSession(configuration: sessionConfiguration)
    private lazy var sessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.httpAdditionalHeaders = sharedHeaders
        return configuration
    }()
}

private extension UrlSessionNetworkService {
    func assembleURLRequest(
        httpMethod: String,
        path: String,
        headerParams: [String: String]?,
        queryParams: [String: String]?,
        body: Encodable?
    ) throws -> URLRequest {
        var urlComponents = URLComponents()

        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryParams?.map(URLQueryItem.init)

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod

        headerParams?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        return urlRequest
    }
}

private extension UrlSessionNetworkService {
    func perform(request: URLRequest) async -> NetworkOperationResult {
        await withCheckedContinuation { [weak self] continuation in
            self?.dataTask(request: request, continuation: continuation)
                .resume()
        }
    }

    func dataTask(
        request: URLRequest,
        continuation: CheckedContinuation<NetworkOperationResult, Never>
    ) -> URLSessionDataTask {

        print("Request:")
        print(request.customDescription)

        return urlSession.dataTask(with: request) { data, response, error in
            print("Response:")
            print(response?.description ?? "")

            let statusCode = (response as? HTTPURLResponse)?.statusCode

            if let error {
                print("Error:")
                print(error.localizedDescription)

                continuation.resume(
                    returning: NetworkOperationResult(
                        statusCode: statusCode,
                        result: .failure(error))
                )
            } else {
                print("Body:")
                print(String(data: data ?? Data(), encoding: .utf8) ?? "")

                continuation.resume(
                    returning: NetworkOperationResult(
                        statusCode: statusCode,
                        result: .success(data ?? Data()))
                )
            }
        }
    }
}

private extension URLRequest {
    var customDescription: String {
        var description = [] as [String]

        if let httpMethod {
            description.append("Method: \(httpMethod)")
        }

        if let url {
            description.append("URL: \(url)")
        }

        if let allHTTPHeaderFields, !allHTTPHeaderFields.isEmpty {
            description.append("Headers: \(allHTTPHeaderFields)")
        }

        if let httpBody {
            description.append("Body: \(httpBody)")
        }

        return description.joined(separator: "\n")
    }
}

private extension HttpMethod {
    var asString: String {
        switch self {
        case .delete: return "DELETE"
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        }
    }
}
