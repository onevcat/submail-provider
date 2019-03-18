import XCTest
import Vapor
@testable import Submail

class MailTests: XCTestCase {
    func testMailRequestParsing() throws {
        let config = SubmailConfig(appID: "123", appKey: "abc")
        var mail = Mail(from: "from address", subject: "mail subject")
        mail.to = "to address"
        mail.fromName = "from name"
        mail.reply = "reply address"
        mail.cc = "cc address"
        mail.bcc = "bcc address"
        mail.text = "plain text"
        mail.html = "<h1>html</h1>"
        mail.vars = JSONString(["foo": "bar"])
        mail.links = JSONString(["boo": "baz"])
        mail.headers = JSONString(["number": 123])
        mail.asynchronous = "true"
        mail.tag = "TAG"

        mail.adapt(in: config)

        let data = try JSONEncoder().encode(mail)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]

        XCTAssertEqual(json["appid"] as? String, "123")
        XCTAssertEqual(json["signature"] as? String, "abc")
        XCTAssertEqual(json["from"] as? String, "from address")
        XCTAssertEqual(json["to"] as? String, "to address")
        XCTAssertEqual(json["from_name"] as? String, "from name")
        XCTAssertEqual(json["reply"] as? String, "reply address")
        XCTAssertEqual(json["cc"] as? String, "cc address")
        XCTAssertEqual(json["bcc"] as? String, "bcc address")
        XCTAssertEqual(json["subject"] as? String, "mail subject")
        XCTAssertEqual(json["text"] as? String, "plain text")
        XCTAssertEqual(json["html"] as? String, "<h1>html</h1>")
        XCTAssertEqual(json["vars"] as? String, "{\"foo\":\"bar\"}")
        XCTAssertEqual(json["links"] as? String, "{\"boo\":\"baz\"}")
        XCTAssertEqual(json["headers"] as? String, "{\"number\":123}")
        XCTAssertEqual(json["asynchronous"] as? String, "true")
        XCTAssertEqual(json["tag"] as? String, "TAG")
    }

    func testMailRequestWithAttachmentParsing() throws {
        let config = SubmailConfig(appID: "123", appKey: "abc")
        var mail = Mail(from: "from address", subject: "mail subject")

        let attachment = Attachment(data: "hello".data(using: .utf8)!, fileName: "hello.txt")
        mail = mail.addingAttachment(attachment)

        mail.adapt(in: config)

        let parts = try mail.multipartData()

        let multipart = try MultipartParser().parse(data: parts.1, boundary: parts.0)
        XCTAssertEqual(multipart.count, 5)

        XCTAssertEqual(try .convertFromMultipartPart(multipart.firstPart(named: "appid")!), "123")
        XCTAssertEqual(try .convertFromMultipartPart(multipart.firstPart(named: "signature")!), "abc")
        XCTAssertEqual(try .convertFromMultipartPart(multipart.firstPart(named: "from")!), "from address")
        XCTAssertEqual(try .convertFromMultipartPart(multipart.firstPart(named: "subject")!), "mail subject")

        let mailAttachement = try Attachment.convertFromMultipartPart(multipart.firstPart(named: "attachments[]")!)
        XCTAssertEqual(mailAttachement, attachment)
    }

    let sentResponse = """
    {
       "status":"success",
       "return": [
           {
             "send_id": "HstDN4",
             "to": "eg@eg.com"
           }
         ]
    }
    """

    func testMailSentResponseParse() throws {
        let body = HTTPBody(string: sentResponse)
        var headers: HTTPHeaders = [:]
        headers.add(name: .contentType, value: MediaType.json.description)
        let response = HTTPResponse(headers: headers, body: body)

        let result = try response.decodeSubmail(SendMailResponse.self)
        XCTAssertEqual(result.return.count, 1)
        XCTAssertEqual(result.return[0].sendID, "HstDN4")
        XCTAssertEqual(result.return[0].to, "eg@eg.com")
    }
}
