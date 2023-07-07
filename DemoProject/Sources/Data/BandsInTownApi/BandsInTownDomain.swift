import RetroSwift
import Foundation

class BandsInTownDomain: Domain {
    override init(transport: HttpTransport) {
        super.init(transport: transport)
        transport.setConfiguration(scheme: "https", host: "rest.bandsintown.com", sharedHeaders: nil)
    }
}
