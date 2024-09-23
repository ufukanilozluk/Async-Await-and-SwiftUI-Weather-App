import Foundation

struct Location: Codable {
  var localizedName: String
  var country: Country
  var geoPosition: GeoPosition?
}

extension Location {
  struct Country: Codable {
    var localizedName: String
  }
  struct GeoPosition: Codable {
    var latitude: Double
    var longitude: Double
  }
}
