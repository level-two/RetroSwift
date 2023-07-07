@propertyWrapper
public struct Query<T: CustomStringConvertible> {
    public let wrappedValue: T
    private let customParamName: String?

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        self.customParamName = nil
    }

    public init(wrappedValue: T, _ customName: String) {
        self.wrappedValue = wrappedValue
        self.customParamName = customName
    }
}

extension Query: HttpRequestParameter {
    func fillHttpRequestFields(
        forParameterWithName paramName: String,
        in builder: HttpRequestParams.Builder
    ) throws {
        let queryParamName = customParamName ?? paramName
        let queryParamValue = wrappedValue.description
        builder.add(queryParams: [queryParamName: queryParamValue])
    }
}
