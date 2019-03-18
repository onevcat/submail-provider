import Vapor

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

extension MultipartPartConvertible {
    func convertToMultipartPart(name: String, mediaType: MediaType? = nil, fileName: String? = nil) throws -> MultipartPart {
        var part = try convertToMultipartPart()
        part.name = name
        part.contentType = mediaType
        part.filename = fileName
        return part
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
