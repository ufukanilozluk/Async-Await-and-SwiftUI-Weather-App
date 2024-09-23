import Foundation

@MainActor
final class CityViewModel: ObservableObject {
    // Published properties to hold location data
    @Published var locationSearchData: [Location] = []
    @Published var cityNames: [String] = []
    @Published var location: [Location] = []

    private let service: CityServiceProtocol

    // Initializer to inject the service dependency
    init(service: CityServiceProtocol) {
        self.service = service
    }

    // Function to find city based on query string using async/await
  func findCity(query: String) async throws {
      do {
          let locations = try await service.findCity(query: query)
          // UI'yi ana iş parçacığında güncelle
          await MainActor.run {
              self.locationSearchData = locations
              self.cityNames = locations.map { "\($0.localizedName), \($0.country.localizedName)" }
          }
      } catch let apiError as APIManager.APIError  {
          throw apiError
      }
  }


    // Function to find coordinates based on query string using async/await
  func findCoordinate(query: String) async throws -> [Location] {
      do {
          let locations = try await service.findCoordinate(query: query)
          // Update UI on the main thread if needed
          await MainActor.run {
              self.location = locations
          }
          return locations
      } catch {
          // Handle errors
          throw error  // Rethrow the error to be handled by the caller
      }
  }
}
