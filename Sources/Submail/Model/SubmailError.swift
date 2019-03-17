import Vapor

public enum SubmailError: Error {

    public struct Response: Content {
        public let code: Int
        public let message: String

        enum CodingKeys: String, CodingKey {
            case code, message = "msg"
        }
    }

    case invalidRequest(Data)
    case errorResponse(Response)
    case invalidResponse(HTTPResponse)
}

extension SubmailError: Debuggable {
    public var identifier: String {
        switch self {
        case .invalidRequest:
            return "SubmailError.invalidRequest"
        case .errorResponse:
            return "SubmailError.errorResponse"
        case .invalidResponse:
            return "SubmailError.invalidResponse"
        }
    }

    public var reason: String {
        switch self {
        case .invalidRequest(let data):
            return "The request is invalid. Data: \(data)"
        case .errorResponse(let response):
            return "Error response from Submail API. Code: \(response.code), message: \(response.message)"
        case .invalidResponse(let response):
            return "Invalid response: \(response)"
        }
    }
}
