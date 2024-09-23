import Foundation

protocol ForecastServiceProtocol {
    func getWeather(city: String, cnt: String) async throws -> Forecast
    func getWeatherForecastWeekly(lat: String, lon: String) async throws -> ForecastWeekly
}

final class ForecastService: ForecastServiceProtocol {
    func getWeather(city: String, cnt: String) async throws -> Forecast {
        do {
            let endPoint = try Endpoint.daily(city: city, cnt: cnt)
            guard let url = endPoint.url else {
                throw APIManager.APIError.invalidURL
            }
            return try await APIManager.shared.getJSON(url: url)
        } catch {
            throw error
        }
    }

    func getWeatherForecastWeekly(lat: String, lon: String) async throws -> ForecastWeekly {
        do {
            let endPoint = try Endpoint.weeklyForecast(lat: lat, lon: lon)
            guard let url = endPoint.url else {
                throw APIManager.APIError.invalidURL
            }
            return try await APIManager.shared.getJSON(url: url)
        } catch {
            throw error
        }
    }
}
