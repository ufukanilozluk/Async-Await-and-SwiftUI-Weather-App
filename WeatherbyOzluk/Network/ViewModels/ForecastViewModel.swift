import UIKit

final class ForecastViewModel: ObservableObject {
    // Observable properties using @Published
    @Published var temperature: String = ""
    @Published var bigIcon: UIImage? = nil
    @Published var description: String = ""
    @Published var visibility: String = ""
    @Published var wind: String = ""
    @Published var humidity: String = ""
    @Published var pressure: String = ""
    @Published var date: String = ""
    @Published var weatherData: [Forecast.Weather] = []
    @Published var weeklyWeatherData: ForecastWeekly? = nil
    @Published var allCitiesWeatherData: [Forecast] = []
    @Published var degree: [String] = []
    @Published var dates: [String] = []
    @Published var times: [String] = []
    @Published var mins: [String] = []
    @Published var maxs: [String] = []
    @Published var days: [String] = []
    @Published var cityNames: [String] = []

    private let service: ForecastServiceProtocol

    // Init
    init(service: ForecastServiceProtocol) {
        self.service = service
    }

    // Get weather for a specific city using async/await
    func getWeather(city: String) async throws {
        do {
            let forecast = try await service.getWeather(city: city, cnt: "7")
            processWeather(forecast)
        } catch {
            throw error
        }
    }

    // Get weekly weather forecast based on latitude and longitude using async/await
    func getWeatherForecastWeekly(lat: String, lon: String) async throws {
        do {
            let weeklyForecast = try await service.getWeatherForecastWeekly(lat: lat, lon: lon)
            processWeeklyWeather(weeklyForecast)
        } catch {
            throw error
        }
    }

    // Fetch weather and weekly forecast for a specific city using async/await
    func getForecast(city: Location) async throws{
        guard let lat = city.geoPosition?.latitude, let lon = city.geoPosition?.longitude else { return }

        do {
            async let weather = try service.getWeather(city: city.localizedName, cnt: "7")
            async let weeklyForecast = try service.getWeatherForecastWeekly(lat: String(lat), lon: String(lon))

            let (fetchedWeather, fetchedWeeklyForecast) = try await (weather, weeklyForecast)
            processWeather(fetchedWeather)
            processWeeklyWeather(fetchedWeeklyForecast)
        } catch {
            throw error
        }
    }

    // Fetch forecast for all selected cities using async/await
    func getForecastForAllCities() async throws {
        let selectedCities: [Location] = UserDefaultsHelper.getCities()

        do {
            let weatherResults = try await withThrowingTaskGroup(of: Forecast.self) { group in
                for city in selectedCities {
                    group.addTask {
                        return try await self.service.getWeather(city: city.localizedName, cnt: "1")
                    }
                }
                return try await group.reduce(into: [Forecast]()) { $0.append($1) }
            }

            processAllCitiesWeather(weatherResults, selectedCities: selectedCities)
        } catch {
          throw error
        }
    }

    // Process weather data for a specific city
    private func processWeather(_ forecast: Forecast) {
        let data = forecast.list[0]
        temperature = "\(Int(data.main.temp))°C"
        bigIcon = UIImage(named: data.weather[0].icon)
        description = data.weather[0].description.capitalized
        visibility = "\(Int(data.visibility / 1000)) km"
        wind = "\(data.wind.deg)m/s"
        humidity = "%\(data.main.humidity)"
        pressure = "\(data.main.pressure) mbar"
        date = data.date.dateAndTimeLong()
        weatherData = forecast.list
        times = forecast.list.enumerated().map { $0.offset == 0 ? "Now" : $0.element.date.timeIn24Hour() }
    }

    // Process weekly weather data
    private func processWeeklyWeather(_ weeklyForecast: ForecastWeekly) {
        weeklyWeatherData = weeklyForecast
        maxs = weeklyForecast.daily.map { "\(Int($0.temp.max))°C" }
        mins = weeklyForecast.daily.map { "\(Int($0.temp.min))°C" }
        days = weeklyForecast.daily.map { $0.date.dayLong() }
    }

    // Process weather data for all selected cities
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
