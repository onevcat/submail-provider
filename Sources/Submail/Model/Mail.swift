import Vapor

public struct Mail: Encodable {

    var appID: String = ""
    var signature: String = ""

    public var to: String?
    public var from: String
    public var fromName: String?
    public var reply: String?
    public var cc: String?
    public var bcc: String?
    public var subject: String
    public var text: String?
    public var html: String?
    public var vars: JSONString?
    public var links: JSONString?
    var attachments: [Data]?
    public var headers: JSONString?
    public var asynchronous: String?
    public var tag: String?

    public init(from: String, subject: String) {
        self.from = from
        self.subject = subject
    }

    mutating func adapt(in config: SubmailConfig) {
        self.appID = config.appID
        self.signature = config.appKey
    }

    public mutating func addAttachment(at path: String) throws {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        addAttachment(data)
    }

    public mutating func addAttachment(_ data: Data) {
        if let attachments = attachments {
            self.attachments = attachments + [data]
        } else {
            self.attachments = [data]
        }
    }

    enum CodingKeys: String, CodingKey {
        case  appID = "appid", signature, to, from, fromName = "from_name",
              reply, cc, bcc, subject, text, html, vars, links, attachments,
              headers, asynchronous
    }
}

public struct MailResponse: Content {

    public struct Return: Content {
        public let sendID: String
        public let to: String
    }

    public let `return`: [Return]
}
