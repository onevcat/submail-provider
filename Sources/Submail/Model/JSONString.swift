import Foundation

public struct JSONString: Encodable {

    public let dictionary: [String: Any]

    public init(_ dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        guard let result = String(data: data, encoding: .utf8) else {
            throw SubmailError.invalidRequest(data)
        }

        try container.encode(result)
    }
}
