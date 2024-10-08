import SwiftUI
import Lottie

struct HomeView: View {
  @StateObject private var viewModel = ForecastViewModel(service: ForecastService())
  @State private var selectedCity: Location?
  @State private var selectedSegmentIndex: Int = 0
  @State private var isRefreshing = false

  
  var body: some View {
    VStack {
      let weatherData = viewModel.weatherData
      if !weatherData.isEmpty {
        ScrollView {
          VStack {
            weatherHeader
            dailyWeatherView
            weeklyWeatherView
          }
          .refreshable {
            await refreshData()
          }
        }
      } else {
        emptyView
      }
    }
    .onAppear {
      updateSegmentedControlItems()
      Task {
        await fetchDataForSelectedCity()
      }
    }
  }

  private var weatherHeader: some View {
    VStack {
      if let image = viewModel.bigIcon {
        image
          .resizable()
          .scaledToFit()
          .frame(width: 100, height: 100)
      }
      Text(viewModel.temperature)
        .font(.largeTitle)
      Text(viewModel.description)
      Text(viewModel.date)
    }
  }

  private var dailyWeatherView: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 4) {
        ForEach(0..<viewModel.times.count, id: \.self) { index in
        let weather = viewModel.weatherData[index]
            if let icon = weather.weather.first?.icon{
              DailyWeatherView(time: viewModel.times[index], icon: icon)
            }
        }
      }
    }
  }

  private var weeklyWeatherView: some View {
      List {
          // weeklyWeather opsiyonel olduğu için güvenli bir şekilde unwrap ediyoruz
        if let weeklyWeather = viewModel.weeklyWeatherData {
              ForEach(0..<weeklyWeather.daily.count, id: \.self) { index in
                  // weather opsiyonel olduğu için güvenli bir şekilde unwrap ediyoruz
                  let weather = weeklyWeather.daily[index]
                  WeeklyWeatherView(day: viewModel.days[index], minTemp: viewModel.mins[index], maxTemp: viewModel.maxs[index], icon: weather.weather.first?.icon ?? "")
              }
          }
      }
  }


  private var emptyView: some View {
    VStack {
      Text("No data available.")
      LottieView(animation: .named("welcome-page"))
        .frame(width: 200, height: 200)
    }
  }

  private func updateSegmentedControlItems() {
    GlobalSettings.selectedCities = UserDefaultsHelper.getCities()
  }

  private func fetchDataForSelectedCity() async {
    let selectedCity = GlobalSettings.selectedCities[selectedSegmentIndex]
      self.selectedCity = selectedCity
      do {
        try await viewModel.getForecast(city: selectedCity)
      } catch {
        // Handle error
      }
  }

  private func refreshData() async {
    guard selectedCity != nil else { return }
    await fetchDataForSelectedCity()
  }
}

struct DailyWeatherView: View {
  let time: String
  let icon: String

  var body: some View {
    VStack {
      Text(time)
      Image(icon)
        .resizable()
        .frame(width: 50, height: 50)
    }
  }
}

struct WeeklyWeatherView: View {
  let day: String
  let minTemp: String
  let maxTemp: String
  let icon: String

  var body: some View {
    HStack {
      Text(day)
      Spacer()
      Text("\(minTemp) - \(maxTemp)")
      Image(icon)
        .resizable()
        .frame(width: 30, height: 30)
    }
  }
}

struct HomeViewPreview: PreviewProvider {
    static var previews: some View {
      HomeView()
            .previewLayout(.sizeThatFits) // Önizleme boyutunu ayarlayın
            .padding() // Önizlemeye dolgu ekleyin
    }
}
