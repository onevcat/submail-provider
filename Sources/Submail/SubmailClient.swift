import Vapor

public final class SubmailClient: Service {

    static let base = "https://api.mysubmail.com"
    static let apiBalanceMail = base + "/balance/mail"
    static let apiMailSend = base + "/mail/send"

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
            let httpResponse = response.http
            switch httpResponse.status {
            case .ok, .accepted:
                return try httpResponse.decodeSubmail(Balance.self)
            default:
                throw SubmailError.invalidResponse(httpResponse)
            }
        }
    }

    public func send(mail: Mail, on workder: Worker) -> Future<MailResponse> {
        let request = client.post(SubmailClient.apiMailSend) { req in
            var mail = mail
            mail.adapt(in: config)
            try req.content.encode(mail, as: .formData)
        }
        return request.map { response in
            let httpResponse = response.http
            switch httpResponse.status {
            case .ok, .accepted:
                return try httpResponse.decodeSubmail(MailResponse.self)
            default:
                throw SubmailError.invalidResponse(httpResponse)
            }
        }
    }
}
