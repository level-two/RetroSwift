@propertyWrapper
public struct Path<T: CustomStringConvertible> {
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

extension Path: HttpRequestParameter {
    func fillHttpRequestFields(
        forParameterWithName paramName: String,
        in builder: HttpRequestParams.Builder
    ) throws {
        let pathComponentName = customParamName ?? paramName
        let pathComponentValue = wrappedValue.description
        builder.set(pathComponent: "{\(pathComponentName)}", filledWith: pathComponentValue)
    }
}
