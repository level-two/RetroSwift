import Foundation

public protocol NetworkProviding: AnyObject {
    var networkService: NetworkService { get }

    func perform<Request, Response: Decodable>(
        request: Request,
        to endpoint: EndpointDescribing
    ) async throws -> Response
}

public extension NetworkProviding {
    func perform<Request, Response: Decodable>(
        request: Request,
        to endpoint: EndpointDescribing
    ) async throws -> Response {

        let operationResult = try await networkService.request(
            httpMethod: endpoint.method,
            path: resolvePath(format: endpoint.path, params: request),
            headerParams: getHeaderParams(from: request),
            queryParams: getQueryParams(from: request),
            body: getBody(from: request))

        let data = try operationResult.result.get()

        let decoder = JSONDecoder()

        if Response.self is ErrorResponseDecoding.Type {
            let isSuccess = (200...299).contains(operationResult.statusCode)
            decoder.userInfo[ErrorResponseDecodingKey.isErrorResponseCodingKey] = !isSuccess
        }

        return try decoder.decode(Response.self, from: data)
    }
}

private extension NetworkProviding {
    func resolvePath<Params>(format: String, params: Params) -> String {
        Mirror(reflecting: params)
            .children
            .reduce(format) { resolved, child in
                guard let path = child.value as? PathDescribing,
                      let paramName = child.label?.dropFirst()
                else { return resolved }

                let name = path.customName ?? String(paramName)

                return resolved.replacingOccurrences(of: "{\(name)}", with: path.value)
            }
    }

    func getQueryParams<Params>(from params: Params) -> [String: String]? {
        let pairs = Mirror(reflecting: params)
            .children
            .compactMap { child -> (String, String)? in
                guard let param = child.value as? QueryDescribing,
                      let paramName = child.label?.dropFirst()
                else { return nil }

                let name = param.customName ?? String(paramName)

                return (name, param.value)
            }

        guard !pairs.isEmpty else { return nil }

        return Dictionary(pairs, uniquingKeysWith: { _, new in new })
    }

    func getHeaderParams<Params>(from params: Params) -> [String: String]? {
        let pairs = Mirror(reflecting: params)
            .children
            .compactMap { child -> (String, String)? in
                guard let param = child.value as? HeaderDescribing,
                      let paramName = child.label?.dropFirst()
                else { return nil }

                let name = param.customName ?? String(paramName)

                return (name, param.value)
            }

        guard !pairs.isEmpty else { return nil }

        return Dictionary(pairs, uniquingKeysWith: { _, new in new })
    }

    func getBody<Params>(from params: Params) -> Encodable? {
        Mirror(reflecting: params)
            .children
            .compactMap { $0.value as? BodyDescribing }
            .first
    }
}

private protocol ErrorResponseDecoding { }

private enum ErrorResponseDecodingKey {
    static var isErrorResponseCodingKey: CodingUserInfoKey {
        .init(rawValue: #function)!
    }
}

extension Either: Decodable, ErrorResponseDecoding {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if decoder.userInfo[ErrorResponseDecodingKey.isErrorResponseCodingKey] as? Bool == true {
            self = try .errorResponse(container.decode(ErrorResponse.self))
        } else {
            self = try .response(container.decode(Response.self))
        }
    }
}
