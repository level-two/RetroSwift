@propertyWrapper
public struct Path<T: CustomStringConvertible>: PathDescribing {
    public let wrappedValue: T
    let customName: String?

    var value: String { wrappedValue.description }

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        self.customName = nil
    }

    public init(wrappedValue: T, _ customName: String) {
        self.wrappedValue = wrappedValue
        self.customName = customName
    }
}
