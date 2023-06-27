import RetroSwift
import Foundation

class BandsInTownDomain: NetworkProviding {
    required init(networkService: NetworkService) {
        self.networkService = networkService

        networkService.setConfiguration(
            scheme: "https",
            host: "rest.bandsintown.com",
            sharedHeaders: ["Content-Type": "application/json"])
    }

    let networkService: NetworkService
}
