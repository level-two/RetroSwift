import Foundation

extension NetworkProviding {
    public enum Either<Response: Decodable, ErrorResponse: Decodable> {
        case response(Response)
        case errorResponse(ErrorResponse)
    }
}
