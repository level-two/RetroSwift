import Foundation

extension Domain {
    @propertyWrapper
    public class Post<Request, Response: Decodable>: EndpointDescribing {
        public typealias NetworkAction = (Request) async throws -> Response

        public let path: String
        public var method: HttpMethod { .post }

        public init(_ path: String) {
            self.path = path
        }

        public static subscript<EnclosingDomain: Domain>(
            _enclosingInstance domain: EnclosingDomain,
            wrapped networkActionKeyPath: ReferenceWritableKeyPath<EnclosingDomain, NetworkAction>,
            storage endpointKeyPath: ReferenceWritableKeyPath<EnclosingDomain, Post>
        ) -> NetworkAction {
            get {
                let endpoint = domain[keyPath: endpointKeyPath]
                return endpoint.customAction ?? { try await domain.perform(request: $0, to: endpoint) }
            }
            set {
                let endpoint = domain[keyPath: endpointKeyPath]
                endpoint.customAction = newValue
            }
        }

        @available(*, unavailable)
        public var wrappedValue: NetworkAction {
            get { fatalError("only works on instance properties of classes") }
            // swiftlint:disable:next unused_setter_value
            set { fatalError("only works on instance properties of classes") }
        }

        private var customAction: NetworkAction?
    }
}
