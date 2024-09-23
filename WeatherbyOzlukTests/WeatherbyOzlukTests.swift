import XCTest
@testable import WeatherbyOzluk

final class WeatherbyOzlukTests: XCTestCase {
  var viewModel: ForecastViewModel!
  var mockService: ForecastMockServiceForSuccess!
  override func setUp() {
    super.setUp()
    mockService = ForecastMockServiceForSuccess()
    viewModel = ForecastViewModel(service: mockService)
  }

  override func tearDown() {
    viewModel = nil
    mockService = nil
    super.tearDown()
  }

  func testForecastViewModel() {
    // Given
    let expectedDailyCount = 8
    let expectedMaxTemp = 32.14
    let expectedMinTemp = 19.82
    let expectedDate = Date(timeIntervalSince1970: 2647522800)
    let expectedIcon = "01d"

    // When
    viewModel.getWeatherForecastWeekly(lat: "37.871", lon: "32.485")

    // Then
    XCTAssertEqual(viewModel.weeklyWeatherData.value?.daily.count, expectedDailyCount)
    XCTAssertEqual(viewModel.weeklyWeatherData.value?.daily[2].temp.max, expectedMaxTemp)
    XCTAssertEqual(viewModel.weeklyWeatherData.value?.daily[2].temp.min, expectedMinTemp)
    XCTAssertEqual(viewModel.weeklyWeatherData.value?.daily[2].date, expectedDate)
    XCTAssertEqual(viewModel.weeklyWeatherData.value?.daily[2].weather[0].icon, expectedIcon)
    XCTAssertEqual(mockService.callCountWeekly, 1)
  }

  func testForecastViewModelWithError() {
    // Given
    mockService.result = .error
    // When
    viewModel.getWeatherForecastWeekly(lat: "37.871", lon: "32.485")
    // Then
    XCTAssertNil(viewModel.weeklyWeatherData.value)
  }

  func testForecastViewModelSpecificDays() {
    // Given
    let expectedForecasts = mockService.forecastWeekly.daily

    // When
    viewModel.getWeatherForecastWeekly(lat: "37.871", lon: "32.485")

    // Then
    for (index, expectedDay) in expectedForecasts.enumerated() {
      XCTAssertEqual(viewModel.weeklyWeatherData.value?.daily[index].date, expectedDay.date)
      XCTAssertEqual(viewModel.weeklyWeatherData.value?.daily[index].temp.min, expectedDay.temp.min)
      XCTAssertEqual(viewModel.weeklyWeatherData.value?.daily[index].temp.max, expectedDay.temp.max)
      XCTAssertEqual(viewModel.weeklyWeatherData.value?.daily[index].weather[0].icon, expectedDay.weather[0].icon)
    }
  }

  func testObservableProperties() {
    // Given
    let expectation = XCTestExpectation(description: "Weekly weather data is updated")

    viewModel.weeklyWeatherData.bind { _ in
      expectation.fulfill()
    }

    // When
    viewModel.getWeatherForecastWeekly(lat: "37.871", lon: "32.485")

    // Then
    wait(for: [expectation], timeout: 1.0)
    XCTAssertNotNil(viewModel.weeklyWeatherData.value)
  }

  func testSingleAPICall() {
    // Given
    XCTAssertEqual(mockService.callCountWeekly, 0, "Initial call count should be 0")

    // When
    viewModel.getWeatherForecastWeekly(lat: "37.871", lon: "32.485")

    // Then
    XCTAssertEqual(mockService.callCountWeekly, 1, "API should be called only once")
  }
}

class ForecastMockServiceForSuccess: ForecastServiceProtocol {
  enum MockResult {
    case success
    case error
  }
  var result: MockResult = .success
  var callCountWeekly = 0
  let forecastWeekly = ForecastWeekly(
    daily: [
      ForecastWeekly.Daily(
        date: Date(timeIntervalSince1970: 2647350000), // 2055-07-07 09:00:00 +0000
        temp: ForecastWeekly.Daily.Temp(min: 16.54, max: 27.99),
        weather: [ForecastWeekly.Daily.Weather(icon: "01d")]
      ),
      ForecastWeekly.Daily(
        date: Date(timeIntervalSince1970: 2647436400), // 2055-07-08 09:00:00 +0000
        temp: ForecastWeekly.Daily.Temp(min: 18.83, max: 30.9),
        weather: [ForecastWeekly.Daily.Weather(icon: "10d")]
      ),
      ForecastWeekly.Daily(
        date: Date(timeIntervalSince1970: 2647522800), // 2055-07-09 09:00:00 +0000
        temp: ForecastWeekly.Daily.Temp(min: 19.82, max: 32.14),
        weather: [ForecastWeekly.Daily.Weather(icon: "01d")]
      ),
      ForecastWeekly.Daily(
        date: Date(timeIntervalSince1970: 2647609200), // 2055-07-10 09:00:00 +0000
        temp: ForecastWeekly.Daily.Temp(min: 20.61, max: 31.45),
        weather: [ForecastWeekly.Daily.Weather(icon: "01d")]
      ),
      ForecastWeekly.Daily(
        date: Date(timeIntervalSince1970: 2647695600), // 2055-07-11 09:00:00 +0000
        temp: ForecastWeekly.Daily.Temp(min: 21.67, max: 29.53),
        weather: [ForecastWeekly.Daily.Weather(icon: "10d")]
      ),
      ForecastWeekly.Daily(
        date: Date(timeIntervalSince1970: 2647782000), // 2055-07-12 09:00:00 +0000
        temp: ForecastWeekly.Daily.Temp(min: 19.95, max: 28.78),
        weather: [ForecastWeekly.Daily.Weather(icon: "10d")]
      ),
      ForecastWeekly.Daily(
        date: Date(timeIntervalSince1970: 2647868400), // 2055-07-13 09:00:00 +0000
        temp: ForecastWeekly.Daily.Temp(min: 19.44, max: 31.92),
        weather: [ForecastWeekly.Daily.Weather(icon: "10d")]
      ),
      ForecastWeekly.Daily(
        date: Date(timeIntervalSince1970: 2647954800), // 2055-07-14 09:00:00 +0000
        temp: ForecastWeekly.Daily.Temp(min: 20.47, max: 31.95),
        weather: [ForecastWeekly.Daily.Weather(icon: "01d")]
      )
    ]
  )
  func getWeather(city: String, cnt: String, completion: @escaping (Result<Forecast, APIManager.APIError>) -> Void) {
  }
  func getWeatherForecastWeekly(lat: String, lon: String, completion: @escaping (Result<ForecastWeekly, APIManager.APIError>) -> Void) {
    callCountWeekly += 1
    switch result {
    case .success:
      completion(.success(forecastWeekly))
    case .error:
      completion(.failure(.timeout))
    }
  }
}
