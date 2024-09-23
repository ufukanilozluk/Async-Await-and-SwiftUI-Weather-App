import Foundation
import Security

enum GlobalSettings {
  static var selectedCities: [Location] = UserDefaultsHelper.getCities()
  static var shouldUpdateSegments = false
  static var formerConnectivityStatus = true
}
