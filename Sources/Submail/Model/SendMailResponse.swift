import Vapor

public struct SendMailResponse: Content {

    public struct Return: Content {
        public let sendID: String
        public let to: String

        enum CodingKeys: String, CodingKey {
            case sendID = "send_id", to
        }
    }

    public let `return`: [Return]
}
