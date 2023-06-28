import Foundation

public struct NetworkOperationResult {
    let statusCode: Int?
    let result: Result<Data, Error>

    public init(statusCode: Int?, result: Result<Data, Error>) {
        self.statusCode = statusCode
        self.result = result
    }
}
