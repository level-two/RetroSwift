import Foundation

public extension Domain {
    enum Either<Response: Decodable, ErrorResponse: Decodable>: Decodable {
        case response(Response)
        case errorResponse(ErrorResponse)
    }
}

private protocol EitherCheckable {
    static var responseType: Any.Type { get }
}

extension Domain.Either: EitherCheckable {
    static var responseType: Any.Type { Response.self }
}

extension Domain {
    static func isEitherWithEmptyResponse(_ type: Any.Type) -> Bool {
        guard let eitherType = type as? EitherCheckable.Type else {
            return false
        }
        return eitherType.responseType is Empty.Type
    }
}

public extension Domain.Either {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if Response.self is Domain.Empty.Type {
            if let errorValue = try? container.decode(ErrorResponse.self) {
                self = .errorResponse(errorValue)
                return
            }
            self = try .response(container.decode(Response.self))
            return
        }

        if let value = try? container.decode(Response.self) {
            self = .response(value)
            return
        }
        let errorValue = try container.decode(ErrorResponse.self)
        self = .errorResponse(errorValue)
    }
}
