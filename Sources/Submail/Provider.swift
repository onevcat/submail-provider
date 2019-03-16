import Vapor

public final class SubmailProvider: Provider {

    public init() { }

    public func register(_ services: inout Services) throws {
        services.register { container -> SubmailClient in
            let httpClient = try container.make(Client.self)
            let config = try container.make(SubmailConfig.self)
            return SubmailClient(client: httpClient, config: config)
        }
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
}

public struct SubmailConfig: Service {
    let appID: String
    let appKey: String
    public init(appID: String, appKey: String) {
        self.appID = appID
        self.appKey = appKey
    }
}
