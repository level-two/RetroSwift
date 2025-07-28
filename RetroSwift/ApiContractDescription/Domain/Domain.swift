import Foundation

open class Domain {
    let transport: HttpTransport

    public init(transport: HttpTransport) {
        self.transport = transport
    }

    open func perform<Request, Response: Decodable>(
        request: Request,
        to endpoint: EndpointDescribing,
        customHeaders: [String: String]? = nil
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
            .map { (paramName: String, param: HttpRequestParameter) in
                if paramName.prefix(1) == "_" {
                    // Remove leading underscore from parameter name
                    (String(paramName.dropFirst()), param)
                } else {
                    (paramName, param)
                }
            }
            .forEach { paramName, param in
                try param.fillHttpRequestFields(forParameterWithName: paramName, in: requestBuilder)
            }

        if let customHeaders {
            requestBuilder.add(headerParams: customHeaders)
        }

        let requestParams = try requestBuilder.buildRequestParams()
        let operationResult = try await transport.sendRequest(with: requestParams)
        let responseData = try operationResult.response.get()

        if responseData.isEmpty, Response.self is Empty.Type {
            // swiftlint:disable:next force_cast
            return Empty() as! Response
        } else {
            return try JSONDecoder().decode(Response.self, from: responseData)
        }
    }
}
