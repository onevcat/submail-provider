import Vapor

public final class SubmailClient: Service {

    static let base = "https://api.mysubmail.com"
    static let apiBalanceMail = base + "/balance/mail"

    let client: Client
    let config: SubmailConfig

    init(client: Client, config: SubmailConfig) {
        self.client = client
        self.config = config
    }

    public func mailBalance(on worker: Worker) -> Future<Balance> {

        let request = client.post(SubmailClient.apiBalanceMail) { req in
            var balance = BalanceRequest()
            balance.adapt(in: self)
            try req.content.encode(balance)
        }
        return request.map { response in
            switch response.http.status {
            case .ok, .accepted:
                return try response.decodeSubmail(Balance.self)
            default:
                throw SubmailError.invalidResponse(response)
            }
        }
    }
}

public struct BalanceRequest: Content {
    var appID: String = ""
    var signature: String = ""

    mutating func adapt(in client: SubmailClient) {
        self.appID = client.config.appID
        self.signature = client.config.appKey
    }
}

public struct Balance: Content {
    public let balance: Int
    public let freeBalance: Int

    enum CodingKeys: String, CodingKey {
        case balance, freeBalance = "free_balance"
    }
}
