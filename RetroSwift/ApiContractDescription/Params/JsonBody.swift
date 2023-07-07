import Foundation

@propertyWrapper
public struct JsonBody<T: Encodable> {
    public let wrappedValue: T
    private let encoder: JSONEncoder

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        self.encoder = JSONEncoder()
    }
}

extension JsonBody: HttpRequestParameter {
    func fillHttpRequestFields(
        forParameterWithName paramName: String,
        in builder: HttpRequestParams.Builder
    ) throws {
        let body = try encoder.encode(wrappedValue)
        builder.set(body: body)
        builder.add(headerParams: ["Content-Type": "application/json"])
    }
}
