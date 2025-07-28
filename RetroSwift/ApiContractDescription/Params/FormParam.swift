import Foundation

@propertyWrapper
public struct FormParam<T: CustomStringConvertible> {
    public let wrappedValue: T
    private let customParamName: String?

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        self.customParamName = nil
    }

    public init(wrappedValue: T, _ customParamName: String) {
        self.wrappedValue = wrappedValue
        self.customParamName = customParamName
    }
}

extension FormParam: HttpRequestParameter {
    func fillHttpRequestFields(
        forParameterWithName paramName: String,
        in builder: HttpRequestParams.Builder
    ) throws {
        builder.add(
            formParam: .init(
                name: customParamName ?? paramName,
                content: wrappedValue.description
            )
        )
    }
}
