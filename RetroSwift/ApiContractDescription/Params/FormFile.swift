import Foundation

@propertyWrapper
public struct FormFile {
    public let wrappedValue: File
    private let customParamName: String?

    public struct File {
        let fileName: String
        let mimeType: String
        let content: Data

        public init(fileName: String, mimeType: String, content: Data) {
            self.fileName = fileName
            self.mimeType = mimeType
            self.content = content
        }

        public static var empty: Self {
            Self(fileName: "", mimeType: "", content: Data())
        }
    }

    public init(wrappedValue: File) {
        self.wrappedValue = wrappedValue
        self.customParamName = nil
    }

    public init(wrappedValue: File, _ customParamName: String) {
        self.wrappedValue = wrappedValue
        self.customParamName = customParamName
    }
}

extension FormFile: HttpRequestParameter {
    func fillHttpRequestFields(
        forParameterWithName paramName: String,
        in builder: HttpRequestParams.Builder
    ) throws {
        builder.add(
            formFile: .init(
                name: customParamName ?? paramName,
                fileName: wrappedValue.fileName,
                mimeType: wrappedValue.mimeType,
                content: wrappedValue.content
            )
        )
    }
}
