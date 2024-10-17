import SwiftUI
import Lottie

struct HomeView: View {
  @StateObject private var viewModel = ForecastViewModel(service: ForecastService())
  @State private var selectedCity: Location?
  @State private var selectedSegmentIndex: Int = 0
  @State private var isRefreshing = false
  @State private var selectedCities: [Location] = GlobalSettings.selectedCities // Burayı değiştirin
  @State private var selectedCitie = true
  
  var body: some View {
    VStack {
      if selectedCitie {
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
      if !selectedCities.isEmpty {
        updateSegmentedControlItems()
        Task {
          await fetchDataForSelectedCity()
        }
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
        ForEach(0..<viewModel.weatherData.count, id: \.self) { index in // Dizilerin uzunluklarını kontrol edin
          let weather = viewModel.weatherData[index]
          if let icon = weather.weather.first?.icon {
            DailyWeatherView(time: viewModel.times[index], icon: icon)
          }
        }
      }
    }
  }

  private var weeklyWeatherView: some View {
    List {
      if let weeklyWeather = viewModel.weeklyWeatherData {
        ForEach(0..<weeklyWeather.daily.count, id: \.self) { index in
          let weather = weeklyWeather.daily[index]
          WeeklyWeatherView(day: viewModel.days[index], minTemp: viewModel.mins[index], maxTemp: viewModel.maxs[index], icon: weather.weather.first?.icon ?? "")
        }
      }
    }
  }

  private var emptyView: some View {
    VStack {
      Text("Start by adding a city")
      LottieView(animation: .named("welcome-page"))
        .playing() // Burayı kontrol edin
        .frame(width: 200, height: 200)
    }
  }

  private func updateSegmentedControlItems() {
    selectedCities = GlobalSettings.selectedCities // Burayı değiştirin
  }

  private func fetchDataForSelectedCity() async {
    guard selectedSegmentIndex < GlobalSettings.selectedCities.count else { return }
    let selectedCity = GlobalSettings.selectedCities[selectedSegmentIndex]
    self.selectedCity = selectedCity
    do {
      try await viewModel.getForecast(city: selectedCity)
    } catch {
      // Hata yönetimi
      print("Error fetching data: \(error)")
    }
  }

  private func refreshData() async {
    guard let selectedCity = selectedCity else { return }
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
