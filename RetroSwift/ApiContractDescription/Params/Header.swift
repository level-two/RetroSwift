@propertyWrapper
public struct Header<T: CustomStringConvertible> {
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

extension Header: HttpRequestParameter {
    func fillHttpRequestFields(
        forParameterWithName paramName: String,
        in builder: HttpRequestParams.Builder
    ) throws {
        let headerParamName = customParamName ?? paramName
        let headerParamValue = wrappedValue.description
        builder.add(headerParams: [headerParamName: headerParamValue])
    }
}
