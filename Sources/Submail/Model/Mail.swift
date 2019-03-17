import Vapor
import Random

public struct Attachment: Encodable {
    public let data: Data
    public let fileName: String?
    public let mediaType: MediaType

    public init(data: Data, fileName: String?, mediaType: MediaType = .binary) {
        self.data = data
        self.fileName = fileName
        self.mediaType = mediaType
    }
}

extension Attachment: MultipartPartConvertible {
    public func convertToMultipartPart() throws -> MultipartPart {
        var result = MultipartPart(data: data)
        result.filename = fileName
        result.contentType = mediaType
        return result
    }

    public static func convertFromMultipartPart(_ part: MultipartPart) throws -> Attachment {
        return Attachment(data: part.data, fileName: part.filename, mediaType: part.contentType ?? .binary)
    }
}

extension MediaType: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(serialize())
    }
}

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
    var attachments: [Attachment]?
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

    public mutating func addAttachment(
        at path: String,
        fileName: String? = nil,
        mediaType: MediaType? = nil) throws
    {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)

        let fileName = fileName ?? url.lastPathComponent
        let mediaType = mediaType ?? MediaType.fileExtension(url.pathExtension)

        addAttachment(data, fileName: fileName, mediaType: mediaType)
    }

    public mutating func addAttachment(_ data: Data, fileName: String?, mediaType: MediaType?) {
        let attachment = Attachment(data: data, fileName: fileName, mediaType: mediaType ?? .binary)
        addAttachment(attachment)
    }

    public mutating func addAttachment(_ attachment: Attachment) {
        if let attachments = attachments {
            self.attachments = attachments + [attachment]
        } else {
            self.attachments = [attachment]
        }
    }

    func multipartData() throws -> (String, Data) {
        let fieldParts = [
            try appID.convertToMultipartPart(name: .appID),
            try signature.convertToMultipartPart(name: .signature),
            try to?.convertToMultipartPart(name: .to),
            try from.convertToMultipartPart(name: .from),
            try fromName?.convertToMultipartPart(name: .fromName),
            try reply?.convertToMultipartPart(name: .reply),
            try cc?.convertToMultipartPart(name: .cc),
            try bcc?.convertToMultipartPart(name: .bcc),
            try subject.convertToMultipartPart(name: .subject),
            try text?.convertToMultipartPart(name: .text),
            try html?.convertToMultipartPart(name: .html),
            try vars?.convertToMultipartPart(name: .vars),
            try links?.convertToMultipartPart(name: .links),
            try headers?.convertToMultipartPart(name: .headers),
            try asynchronous?.convertToMultipartPart(name: .asynchronous),
            try tag?.convertToMultipartPart(name: .tag)
        ]

        let attachmentParts = try attachments?.map {
            try $0.convertToMultipartPart(name: .attachments, mediaType: $0.mediaType, fileName: $0.fileName)
        }

        let allParts = (fieldParts.compactMap { $0 }) + (attachmentParts ?? [])

        let random = OSRandom().generateData(count: 16)
        let boundary: String = "---submailBoundary\(random.hexEncodedString())"

        return (boundary, try MultipartSerializer().serialize(parts: allParts, boundary: boundary))
    }

    enum CodingKeys: String, CodingKey {
        case  appID = "appid", signature, to, from, fromName = "from_name",
              reply, cc, bcc, subject, text, html, vars, links, attachments = "attachments[]",
              headers, asynchronous, tag
    }
}

public struct MailResponse: Content {

    public struct Return: Content {
        public let sendID: String
        public let to: String

        enum CodingKeys: String, CodingKey {
            case sendID = "send_id", to
        }
    }

    public let `return`: [Return]
}

extension MultipartPartConvertible {
    func convertToMultipartPart(
        name: Mail.CodingKeys,
        mediaType: MediaType? = nil,
        fileName: String? = nil)
    throws -> MultipartPart
    {
        return try convertToMultipartPart(name: name.rawValue, mediaType: mediaType, fileName: fileName)
    }
}

extension JSONString: MultipartPartConvertible {
    public func convertToMultipartPart() throws -> MultipartPart {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return MultipartPart(data: data)
    }

    public static func convertFromMultipartPart(_ part: MultipartPart) throws -> JSONString {
        guard let obj = try JSONSerialization.jsonObject(with: part.data, options: []) as? [String: Any] else {
            throw MultipartError(identifier: "JSONString", reason: "Could not convert `Data` to `\(JSONString.self)`.")
        }
        return JSONString(obj)
    }
}

extension MultipartPartConvertible {
    func convertToMultipartPart(name: String, mediaType: MediaType? = nil, fileName: String? = nil) throws -> MultipartPart {
        var part = try convertToMultipartPart()
        part.name = name
        part.contentType = mediaType
        part.filename = fileName
        return part
    }
}
