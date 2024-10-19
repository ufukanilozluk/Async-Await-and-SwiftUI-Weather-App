import SwiftUI
import Observation

@Observable
final class ForecastViewModel {
  // Observable properties
  var temperature = ""
  var bigIcon: Image? = nil
  var description = ""
  var visibility = ""
  var wind = ""
  var humidity = ""
  var pressure = ""
  var date = ""
  var weatherData: [Forecast.Weather] = []
  var weeklyWeatherData: ForecastWeekly? = nil
  var allCitiesWeatherData: [Forecast] = []
  var degree: [String] = []
  var dates: [String] = []
  var times: [String] = []
  var mins: [String] = []
  var maxs: [String] = []
  var days: [String] = []
  var cityNames: [String] = []

  private let service: ForecastServiceProtocol

  // Init
  init(service: ForecastServiceProtocol) {
    self.service = service
  }

  // Get weather for a specific city using async/await
  func getWeather(city: String) async throws {
    let forecast = try await service.getWeather(city: city, cnt: "7")
    await processWeather(forecast)
  }

  // Get weekly weather forecast by coordinates using async/await
  func getWeatherForecastWeekly(lat: String, lon: String) async throws {
    let weeklyForecast = try await service.getWeatherForecastWeekly(lat: lat, lon: lon)
    await processWeeklyWeather(weeklyForecast)
  }

  // Fetch weather and weekly forecast for a city using async/await
  func getForecast(city: Location) async throws {
    guard let lat = city.geoPosition?.latitude,
          let lon = city.geoPosition?.longitude else { return }

    async let weather = service.getWeather(city: city.localizedName, cnt: "7")
    async let weeklyForecast = service.getWeatherForecastWeekly(lat: String(lat), lon: String(lon))

    let (fetchedWeather, fetchedWeeklyForecast) = try await (weather, weeklyForecast)
    await processWeather(fetchedWeather)
    await processWeeklyWeather(fetchedWeeklyForecast)
  }

  // Fetch forecast for all selected cities using async/await
  func getForecastForAllCities() async throws {
    let selectedCities = UserDefaultsHelper.getCities()

    let weatherResults = try await withThrowingTaskGroup(of: Forecast.self) { group in
      for city in selectedCities {
        group.addTask {
          try await self.service.getWeather(city: city.localizedName, cnt: "1")
        }
      }
      return try await group.reduce(into: [Forecast]()) { $0.append($1) }
    }

    await processAllCitiesWeather(weatherResults, selectedCities: selectedCities)
  }

  @MainActor
  private func processWeather(_ forecast: Forecast) {
    let data = forecast.list[0]
    temperature = "\(Int(data.main.temp))°C"
    bigIcon = Image(data.weather[0].icon)
    description = data.weather[0].description.capitalized
    visibility = "\(Int(data.visibility / 1000)) km"
    wind = "\(data.wind.deg)m/s"
    humidity = "%\(data.main.humidity)"
    pressure = "\(data.main.pressure) mbar"
    date = data.date.dateAndTimeLong()
    weatherData = forecast.list
    times = forecast.list.enumerated().map { $0.offset == 0 ? "Now" : $0.element.date.timeIn24Hour() }
  }

  @MainActor
  private func processWeeklyWeather(_ weeklyForecast: ForecastWeekly) {
    weeklyWeatherData = weeklyForecast
    maxs = weeklyForecast.daily.map { "\(Int($0.temp.max))°C" }
    mins = weeklyForecast.daily.map { "\(Int($0.temp.min))°C" }
    days = weeklyForecast.daily.map { $0.date.dayLong() }
  }

  @MainActor
  private func processAllCitiesWeather(_ weather: [Forecast], selectedCities: [Location]) {
    let sortedWeather = weather.sorted { weather1, weather2 in
      guard let cityName1 = weather1.city?.name.replacingOccurrences(of: " Province", with: ""),
            let cityName2 = weather2.city?.name.replacingOccurrences(of: " Province", with: ""),
            let index1 = selectedCities.firstIndex(where: { $0.localizedName == cityName1 }),
            let index2 = selectedCities.firstIndex(where: { $0.localizedName == cityName2 }) else {
        return false
      }
      return index1 < index2
    }

    allCitiesWeatherData = sortedWeather
    let temp = sortedWeather.compactMap { $0.list.first }
    degree = temp.map { "\(Int($0.main.temp))°C" }
    dates = temp.map { $0.date.dateAndTimeLong() }
    cityNames = sortedWeather.compactMap { $0.city?.name.replacingOccurrences(of: " Province", with: "") }
  }
}
