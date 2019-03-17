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
            balance.adapt(in: config)
            try req.content.encode(balance)
        }
        return request.map { response in
            switch response.http.status {
            case .ok, .accepted:
                return try response.http.decodeSubmail(Balance.self)
            default:
                throw SubmailError.invalidResponse(response.http)
            }
        }
    }
}
