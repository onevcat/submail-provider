
import Vapor

extension ContentContainer where M: Vapor.Response {
    func decodeSubmail<D: Decodable>(_ type: D.Type) throws -> Future<D> {
        do {
            return try decode(type)
        } catch {
            let response = try decode(SubmailError.Response.self).wait()
            throw SubmailError.errorResponse(response)
        }
    }
}
