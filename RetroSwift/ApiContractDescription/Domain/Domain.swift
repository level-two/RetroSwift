import Foundation

open class Domain {
    let transport: HttpTransport

    public init(transport: HttpTransport) {
        self.transport = transport
    }

    public func perform<Request, Response: Decodable>(
        request: Request,
        to endpoint: EndpointDescribing
    ) async throws -> Response {
        let requestBuilder = HttpRequestParams.Builder()
        requestBuilder.set(httpMethod: endpoint.method)
        requestBuilder.set(path: endpoint.path)

        try Mirror(reflecting: request)
            .children
            .compactMap { child in
                guard let paramName = child.label,
                      let param = child.value as? HttpRequestParameter
                else { return nil }
                return (paramName, param)
            }
            .forEach { (paramName: String, param: HttpRequestParameter) in
                try param.fillHttpRequestFields(forParameterWithName: paramName, in: requestBuilder)
            }

        let requestParams = try requestBuilder.buildRequestParams()
        let operationResult = try await transport.sendRequest(with: requestParams)
        let responseData = try operationResult.response.get()

        if Response.self is ErrorResponseDecoding.Type, let statusCode = operationResult.statusCode {
            let decoder = JSONDecoder()
            let isSuccess = (200...299).contains(statusCode)
            decoder.userInfo[ErrorResponseDecodingKey.isErrorResponseCodingKey] = !isSuccess
            return try decoder.decode(Response.self, from: responseData)
        } else {
            let decoder = JSONDecoder()
            return try decoder.decode(Response.self, from: responseData)
        }
    }
}

private protocol ErrorResponseDecoding { }

private enum ErrorResponseDecodingKey {
    static var isErrorResponseCodingKey: CodingUserInfoKey {
        .init(rawValue: #function)!
    }
}

extension Domain.Either: Decodable, ErrorResponseDecoding {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if decoder.userInfo[ErrorResponseDecodingKey.isErrorResponseCodingKey] as? Bool == true {
            self = try .errorResponse(container.decode(ErrorResponse.self))
        } else {
            self = try .response(container.decode(Response.self))
        }
    }
}
