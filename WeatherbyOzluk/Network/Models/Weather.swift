import Foundation

struct City: Codable {
  var name: String
  var country: String
  var coord: Coordinate
}

extension City {
  struct Coordinate: Codable {
    var lat: Double
    var lon: Double
  }
}

struct Forecast: Codable {
  var list: [Weather]
  var city: City?
}

extension Forecast {
  struct Weather: Codable {
    var main: WeatherMain
    var weather: [Weather]
    var wind: Wind
    var visibility: Double
    var date: Date
  }
}

extension Forecast.Weather {
  private enum CodingKeys: String, CodingKey {
    case main, weather, wind, visibility
    case date = "dt"
  }
}

extension Forecast.Weather {
  struct WeatherMain: Codable {
    var temp: Double
    var humidity: Int
    var pressure: Int
  }

  struct Weather: Codable {
    var id: Int
    var main: String
    var description: String
    var icon: String
  }

  struct Wind: Codable {
    var speed: Double
    var deg: Int
  }
}

struct ForecastWeekly: Codable {
  var daily: [Daily]
}

extension ForecastWeekly {
  struct Daily: Codable {
    var date: Date
    var temp: Temp
    var weather: [Weather]
  }
}

extension ForecastWeekly.Daily {
  struct Temp: Codable {
    var min: Double
    var max: Double
  }
  struct Weather: Codable {
    var icon: String
  }
  private enum CodingKeys: String, CodingKey {
    case temp, weather
    case date = "dt"
  }
}
