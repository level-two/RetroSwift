import RetroSwift
import Foundation

class BandsInTownDomain: NetworkProviding {
    override init(networkService: NetworkService) {
        super.init(networkService: networkService)

        networkService.setConfiguration(
            scheme: "https",
            host: "rest.bandsintown.com",
            sharedHeaders: ["Content-Type": "application/json"])
    }
}
