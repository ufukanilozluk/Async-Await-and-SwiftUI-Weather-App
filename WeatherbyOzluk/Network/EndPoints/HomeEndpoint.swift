import Foundation

extension Endpoint {
  static func daily(
    city: String,
    cnt: String,
    lang: String = "en",
    units: String = "metric"
  ) throws -> Self {
    guard let appId = KeychainHelper.getApiKey(forKey: "openweather") else {
      throw EndpointError.missingAPIKey
    }
    return Endpoint(
      host: "api.openweathermap.org",
      path: "data/2.5/forecast",
      queryItems: [
        URLQueryItem(name: "appid", value: appId),
        URLQueryItem(name: "cnt", value: cnt),
        URLQueryItem(name: "lang", value: lang),
        URLQueryItem(name: "units", value: units),
        URLQueryItem(name: "q", value: city)
      ]
    )
  }

  static func weeklyForecast(
    exclude: String = "current,minutely,hourly,alerts",
    units: String = "metric",
    lat: String,
    lon: String
  ) throws -> Self {
    guard let appId = KeychainHelper.getApiKey(forKey: "openweather") else {
      throw EndpointError.missingAPIKey
    }
    return Endpoint(
      host: "api.openweathermap.org",
      path: "data/2.5/onecall",
      queryItems: [
        URLQueryItem(name: "appid", value: appId),
        URLQueryItem(name: "exclude", value: exclude),
        URLQueryItem(name: "lat", value: lat),
        URLQueryItem(name: "lon", value: lon),
        URLQueryItem(name: "units", value: units)
      ]
    )
  }
}
