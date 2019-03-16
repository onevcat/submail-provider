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

    func mailBalance(on worker: Worker) -> Future<Balance> {

        let request = client.post(SubmailClient.apiBalanceMail)
        return request.flatMap { response in
            switch response.http.status {
            case .ok, .accepted:
                return try response.content.decodeSubmail(Balance.self)
            default:
                throw SubmailError.invalidResponse(response)
            }
        }
    }
}

public struct Balance: Content {
    public let balance: Int
    public let freeBalance: Int

    enum CodingKeys: String, CodingKey {
        case balance, freeBalance = "free_balance"
    }
}
