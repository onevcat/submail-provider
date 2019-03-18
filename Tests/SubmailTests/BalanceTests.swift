import XCTest
import Vapor
@testable import Submail

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

    func testBalanceRequestParsing() throws {
        let config = SubmailConfig(appID: "123", appKey: "abc")
        var balance = BalanceRequest()
        balance.adapt(in: config)
        let data = try JSONEncoder().encode(balance)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(json["appid"] as? String, "123")
        XCTAssertEqual(json["signature"] as? String, "abc")
    }

    let errorResponse = """
    {
      "status": "error",
      "code": 123,
      "msg": "error reason"
    }
    """
    func testBalanceErrorParsing() throws {
        let body = HTTPBody(string: errorResponse)
        var headers: HTTPHeaders = [:]
        headers.add(name: .contentType, value: MediaType.json.description)
        let response = HTTPResponse(headers: headers, body: body)

        XCTAssertThrowsError(try response.decodeSubmail(Balance.self), "Should throw error") { error in
            guard let error = error as? SubmailError else {
                XCTFail("Should catch SubmailError.")
                return
            }
            guard case .errorResponse(let res) = error else {
                XCTFail("Should catch SubmailError.errorResponse.")
                return
            }
            XCTAssertEqual(res.code, 123)
            XCTAssertEqual(res.message, "error reason")
        }
    }
}
