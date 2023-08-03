Pod::Spec.new do |s|
    s.name                      = "RetroSwift"
    s.summary                   = "Retrofit-like API contract definition in Swift"
    s.version                   = "0.1.2"
    s.license                   = { :type => "MIT", :file => "LICENSE" }
    s.author                    = { "Yauehni Lychkouski" => "" }
    s.homepage                  = "https://github.com/level-two/RetroSwift"
    s.macos.deployment_target   = '10.15'
    s.ios.deployment_target     = '13.0'
    s.tvos.deployment_target    = '13.0'
    s.watchos.deployment_target = '6.0'
    s.swift_version             = '5.6'
    s.source                    = { :git => "https://github.com/level-two/RetroSwift.git", :tag => s.version }
    s.source_files              = "RetroSwift/**/*.{swift}"

    s.description               = <<-DESC
        RetroSwift introduces Retrofit-like approach to endpoint contract description, i.e

        final class SchedulesApi: ApiDomain {
          @Get("/api/v1/schedule")
          var getSchedules: (GetSchedulesRequest) async throws -> GetSchedulesResponse
        }

        struct GetSchedulesRequest {
          @Query var page: Int
          @Query("limit") var schedulesPerPage: Int = 0
          @Header("X-Account-Id") var accountId: String = ""
        }

        let transport: HttpTransport = ....
        let api = SchedulesApi(transport: transport)

        let request = GetSchedulesRequest(page: 1, schedulesPerPage: 30, accountId: "acc_id")
        let response = try await api.getSchedules(request)
    DESC

end
