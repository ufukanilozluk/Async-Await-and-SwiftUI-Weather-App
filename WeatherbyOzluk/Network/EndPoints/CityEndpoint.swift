import Foundation

extension Endpoint {
  static func findCity(query: String) throws -> Self {
    guard let apikey = KeychainHelper.getApiKey(forKey: "accuweather") else {
      throw EndpointError.missingAPIKey
    }
    return Endpoint(
      host: "dataservice.accuweather.com",
      path: "locations/v1/cities/autocomplete",
      queryItems: [
        URLQueryItem(name: "apikey", value: apikey),
        URLQueryItem(name: "q", value: query)
      ]
    )
  }

  static func findCoordinate(query: String) throws -> Self {
    guard let apikey = KeychainHelper.getApiKey(forKey: "accuweather") else {
      throw EndpointError.missingAPIKey
    }
    return Endpoint(
      host: "dataservice.accuweather.com",
      path: "locations/v1/search",
      queryItems: [
        URLQueryItem(name: "apikey", value: apikey),
        URLQueryItem(name: "q", value: query)
      ]
    )
  }
}
