import Foundation

protocol CityServiceProtocol {
  func findCity(query: String) async throws -> [Location]
  func findCoordinate(query: String) async throws -> [Location]
}

final class CityService: CityServiceProtocol {
  func findCity(query: String) async throws -> [Location] {
    do {
      let endPoint = try Endpoint.findCity(query: query)
      guard let url = endPoint.url else {
        throw APIManager.APIError.invalidURL
      }
      return try await APIManager.shared.getJSON(url: url, keyDecodingStrategy: .convertFromPascalCase)
    } catch {
      throw APIManager.APIError.missingAPIKey
    }
  }

  func findCoordinate(query: String) async throws -> [Location] {
    let searchText = query.replacingOccurrences(of: " ", with: "%20")
    do {
      let endPoint = try Endpoint.findCoordinate(query: searchText)
      guard let url = endPoint.url else {
        throw APIManager.APIError.invalidURL
      }
      return try await APIManager.shared.getJSON(url: url, keyDecodingStrategy: .convertFromPascalCase)
    } catch {
      throw APIManager.APIError.missingAPIKey
    }
  }
}
