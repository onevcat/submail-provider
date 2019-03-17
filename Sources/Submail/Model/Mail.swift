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
    public var attachments: [String]?
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

    enum CodingKeys: String, CodingKey {
        case  appID = "appid", signature, to, from, fromName = "from_name",
              reply, cc, bcc, subject, text, html, vars, links, attachments,
              headers, asynchronous
    }
}
