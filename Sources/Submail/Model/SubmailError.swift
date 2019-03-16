import Vapor

public enum SubmailError: Error {

    public struct Response: Content {
        public let code: String
        public let message: String

        enum CodingKeys: String, CodingKey {
            case code, message = "msg"
        }
    }

    case invalidRequest(Data)
    case errorResponse(Response)
    case invalidResponse(Vapor.Response)
}


