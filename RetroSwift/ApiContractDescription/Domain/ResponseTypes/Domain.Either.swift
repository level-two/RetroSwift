import Foundation

extension Domain {
    public enum Either<Response: Decodable, ErrorResponse: Decodable>: Decodable {
        case response(Response)
        case errorResponse(ErrorResponse)
    }
}

extension Domain.Either {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(Response.self) {
            self = .response(value)
        } else {
            let errorValue = try container.decode(ErrorResponse.self)
            self = .errorResponse(errorValue)
        }
    }
}
