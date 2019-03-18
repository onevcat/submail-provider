import Vapor
import Random

public struct Attachment: Encodable, Equatable {
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

    public func addingAttachment(
        on request: Request,
        at path: String,
        fileName: String? = nil,
        mediaType: MediaType? = nil) throws -> Future<Mail>
    {
        let fileIO = try request.fileio()
        return fileIO.read(file: path).map { data in
            let url = URL(fileURLWithPath: path)
            let fileName = fileName ?? url.lastPathComponent
            let mediaType = mediaType ?? MediaType.fileExtension(url.pathExtension)
            return self.addingAttachment(data, fileName: fileName, mediaType: mediaType)
        }
    }

    public func addingAttachment(_ data: Data, fileName: String?, mediaType: MediaType?) -> Mail {
        let attachment = Attachment(data: data, fileName: fileName, mediaType: mediaType ?? .binary)
        return addingAttachment(attachment)
    }

    public func addingAttachment(_ attachment: Attachment) -> Mail {
        var mail = self
        if let attachments = attachments {
            mail.attachments = attachments + [attachment]
        } else {
            mail.attachments = [attachment]
        }
        return mail
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
