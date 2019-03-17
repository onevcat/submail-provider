
import Vapor

extension HTTPResponse {
    func decodeSubmail<D: Decodable>(_ type: D.Type) throws -> D {
        let decoder = JSONDecoder()
        let data = body.data ?? Data()
        do {
            let result = try decoder.decode(type, from: data)
            return result
        } catch {
            do {
                let response = try decoder.decode(SubmailError.Response.self, from: data)
                throw SubmailError.errorResponse(response)
            } catch {
                throw SubmailError.invalidResponse(self)
            }
        }
    }
}
