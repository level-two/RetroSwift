public protocol EndpointDescribing {
    var path: String { get }
    var method: HttpMethod { get }
}
