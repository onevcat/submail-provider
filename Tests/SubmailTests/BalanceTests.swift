
import XCTest
@testable import Submail
import Vapor

class BalanceTests: XCTestCase {
    let balanceResponse = """
    {
      "status": "success",
      "balance": 50,
      "free_balance": 150
    }
    """

    func testBalanceResponseParsing() throws {

        let body = HTTPBody(string: balanceResponse)
        var headers: HTTPHeaders = [:]
        headers.add(name: .contentType, value: MediaType.json.description)
        let response = HTTPResponse(headers: headers, body: body)

        let balance = try response.decodeSubmail(Balance.self)
        XCTAssertEqual(balance.balance, 50)
        XCTAssertEqual(balance.freeBalance, 150)
    }

    let errorResponse = """
    {
        
    }
    """

    func testBalanceRequestParsing() throws {
        let config = SubmailConfig(appID: "123", appKey: "abc")
        var balance = BalanceRequest()
        balance.adapt(in: config)
        let data = try JSONEncoder().encode(balance)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(json["appid"] as? String, "123")
        XCTAssertEqual(json["signature"] as? String, "abc")
    }
}
