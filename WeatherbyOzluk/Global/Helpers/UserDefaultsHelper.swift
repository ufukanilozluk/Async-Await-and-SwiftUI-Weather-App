import Foundation

enum UserDefaultsHelper {
  static func getCities() -> [Location] {
    guard let cityList = UserDefaults.standard.array(forKey: "cities") as? [[String: Any]] else { return [] }
    return cityList.compactMap { city in
      guard let cityName = city["city"] as? String,
        let countryDict = city["country"] as? [String: Any],
        let countryName = countryDict["LocalizedName"] as? String,
        let latitude = city["latitude"] as? Double,
        let longitude = city["longitude"] as? Double
      else { return nil }
      let country = Location.Country(localizedName: countryName)
      let geoPosition = Location.GeoPosition(latitude: latitude, longitude: longitude)
      return Location(localizedName: cityName, country: country, geoPosition: geoPosition)
    }
  }

  static func saveCity(city: Location) {
    var cities = getCitiesDictionaries()
    guard let latitude = city.geoPosition?.latitude, let longitude = city.geoPosition?.longitude else { return }
    let newCity: [String: Any] = [
      "city": city.localizedName,
      "country": ["LocalizedName": city.country.localizedName],
      "latitude": latitude,
      "longitude": longitude
    ]
    cities.append(newCity)
    UserDefaults.standard.set(cities, forKey: "cities")
    }

  static func moveCity(_ first: Int, _ second: Int) {
    var cities = getCitiesDictionaries()
    guard first < cities.count, second < cities.count else { return }
    cities.swapAt(first, second)
    UserDefaults.standard.set(cities, forKey: "cities")
  }
  static func removeCity(index: Int) {
    var cities = getCitiesDictionaries()
    guard index < cities.count else { return }
    cities.remove(at: index)
    UserDefaults.standard.set(cities, forKey: "cities")
  }
  private static func getCitiesDictionaries() -> [[String: Any]] {
    return UserDefaults.standard.array(forKey: "cities") as? [[String: Any]] ?? []
  }
}
