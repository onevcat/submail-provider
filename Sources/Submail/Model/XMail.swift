import Vapor

public struct XMail: Encodable {

    var appID: String = ""
    var signature: String = ""

    public var to: String?
    public var from: String?
    public var fromName: String?
    public var reply: String?
    public var cc: String?
    public var bcc: String?
    public var subject: String?
    public var project: String
    public var vars: JSONString?
    public var links: JSONString?
    public var headers: JSONString?
    public var asynchronous: String?
    public var tag: String?

    public init(project: String) {
        self.project = project
    }

    mutating func adapt(in config: SubmailConfig) {
        self.appID = config.appID
        self.signature = config.appKey
    }

    enum CodingKeys: String, CodingKey {
        case  appID = "appid", signature, to, from, fromName = "from_name",
        reply, cc, bcc, subject, project, vars, links, headers, asynchronous, tag
    }
}
