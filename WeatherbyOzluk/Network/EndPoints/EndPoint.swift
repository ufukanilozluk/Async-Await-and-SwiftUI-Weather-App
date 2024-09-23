import Foundation

enum EndpointError: Error {
  case missingAPIKey
}

struct Endpoint {
  private let host: String
  private let path: String
  private let queryItems: [URLQueryItem]
  init(host: String, path: String, queryItems: [URLQueryItem] = []) {
    self.host = host
    self.path = path
    self.queryItems = queryItems
  }
}
extension Endpoint {
  var url: URL? {
    var components = URLComponents()
    components.scheme = "https"
    components.host = host
    components.path = "/\(path)"
    components.queryItems = queryItems.isEmpty ? nil : queryItems
    return components.url
  }
}
