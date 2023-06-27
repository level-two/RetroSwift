import Foundation

public protocol NetworkProviding: AnyObject {
    func perform<Request, Response: Decodable>(
        request: Request,
        to endpoint: EndpointDescribing
    ) async throws -> Response
}

public extension NetworkProviding {
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
