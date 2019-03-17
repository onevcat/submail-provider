import Vapor

public struct BalanceRequest: Content {
    var appID: String = ""
    var signature: String = ""

    mutating func adapt(in config: SubmailConfig) {
        self.appID = config.appID
        self.signature = config.appKey
    }

    enum CodingKeys: String, CodingKey {
        case appID = "appid", signature
    }
}

public struct Balance: Content {
    public let balance: Int
    public let freeBalance: Int

    enum CodingKeys: String, CodingKey {
        case balance, freeBalance = "free_balance"
    }
}
