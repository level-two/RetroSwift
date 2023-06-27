import Foundation

@propertyWrapper
public struct Body<T: Encodable>: BodyDescribing {
    public let wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}
