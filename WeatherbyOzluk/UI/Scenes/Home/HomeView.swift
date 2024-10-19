import SwiftUI
import Lottie

struct HomeView: View {
    private var viewModel = ForecastViewModel(service: ForecastService())
    @State private var selectedCity: Location?
    @State private var shouldUpdateSegments: Bool = GlobalSettings.shouldUpdateSegments
    @State private var selectedSegmentIndex: Int = 0
    @State private var selectedCities: [Location] = GlobalSettings.selectedCities

    var body: some View {
        VStack {
            contentView
        }
        .onAppear {
            print("Fetching data for selected city")
            Task {
                await fetchDataForSelectedCity()
            }
        }
        .onChange(of: selectedSegmentIndex) {
            Task {
                await fetchDataForSelectedCity()
            }
        }
    }

    private var contentView: some View {
        Group {
            if selectedCities.isEmpty {
                emptyView
            } else {
                ScrollView {
                    VStack {
                        segmentedControl
                        weatherHeader
                        dailyWeatherView
                        weatherOther
                        weeklyWeatherView
                    }
                    .refreshable {
                        await refreshData()
                    }
                }
            }
        }
    }

    private var segmentedControl: some View {
        Picker("Select City", selection: $selectedSegmentIndex) {
            ForEach(0..<selectedCities.count, id: \.self) { index in
                Text(selectedCities[index].localizedName).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
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
  
  private var weatherOther: some View {
      VStack {
        Text(viewModel.visibility)
        Text(viewModel.pressure)
        Text(viewModel.humidity)
        Text(viewModel.wind)
      }
  }

    private var dailyWeatherView: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                ForEach(0..<viewModel.weatherData.count, id: \.self) { index in
                    let weather = viewModel.weatherData[index]
                    if let icon = weather.weather.first?.icon {
                        DailyWeatherView(time: viewModel.times[index], icon: icon)
                    }
                }
            }
        }
    }

  private var weeklyWeatherView: some View {
      ScrollView {
          VStack {
              if let weeklyData = viewModel.weeklyWeatherData {
                  ForEach(weeklyData.daily, id: \.date) { weather in
                      WeeklyWeatherView(
                          day: weather.date.dayLong(),
                          minTemp: "\(Int(weather.temp.min))°C",
                          maxTemp: "\(Int(weather.temp.max))°C",
                          icon: weather.weather.first?.icon ?? ""
                      )
                  }
              } else {
                  Text("No data available")
                      .foregroundColor(.gray)
              }
          }
          .padding()
          .frame(height: 300) // Yüksekliği burada ayarlayabilirsiniz
      }
  }


    private var emptyView: some View {
        VStack {
            Text("Start by adding a city")
            LottieView(animation: .named("welcome-page"))
                .playing()
                .frame(width: 200, height: 200)
        }
    }

    private func fetchDataForSelectedCity() async {
        guard selectedSegmentIndex < selectedCities.count else { return }
        let selectedCity = selectedCities[selectedSegmentIndex]
        self.selectedCity = selectedCity
        do {
            try await viewModel.getForecast(city: selectedCity)
        } catch {
            print("Error fetching data: \(error)")
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
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
