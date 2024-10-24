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
    VStack {
      if selectedCities.isEmpty {
        emptyView
      } else {
        ScrollView(showsIndicators: false) {
          VStack {
            segmentedControl
            CardView { weatherHeader }
            CardView { dailyWeatherView }
            CardView { weatherOther }
            CardView { weeklyWeatherView }
          }
        }
        .refreshable {
          await refreshData()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
          Color.clear.frame(height: 32) // Alt kısma görünmez bir boşluk ekledik
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
    VStack(spacing: 8) { // Öğeler arası boşluk 8 olarak ayarlandı
      if let image = viewModel.bigIcon {
        image
          .resizable()
          .scaledToFit()
          .frame(width: 80, height: 80)
      }
      Text(viewModel.temperature)
        .font(.custom("Roboto", size: 24))
        .foregroundStyle(.colorPurple)
      Text(viewModel.description)
        .font(.custom("Roboto", size: 20))
        .foregroundStyle(.colorPurple)
      Text(viewModel.date)
        .font(.custom("Roboto", size: 16))
        .foregroundStyle(.colorPurple)
    }
    .multilineTextAlignment(.center) // Metinleri ortaladı
    .frame(maxWidth: .infinity) // Ekranın tamamına yayılmasını sağladı
  }

  
  private var weatherOther: some View {
    VStack {
      // Sol sütun: Görünürlük ve Basınç
      HStack(spacing: 12) {
        HStack {
          Image(.eye)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
          Text(viewModel.visibility)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.custom("Roboto", size: 18))
        }
        Spacer()
        HStack {
          Image(.pressure)
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
          Text(viewModel.pressure)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.custom("Roboto", size: 18))
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading) // Sol hizalama

      // Sağ sütun: Nem ve Rüzgar
      HStack(spacing: 12) {
        HStack {
          Image(.waterdrop)
            .resizable()
            .frame(width: 30, height: 30)
          Text(viewModel.humidity)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.custom("Roboto", size: 18))
        }
        Spacer()
        HStack {
          Image(.wind)
            .resizable()
            .frame(width: 30, height: 30)
          Text(viewModel.wind)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.custom("Roboto", size: 18))
        }
      }
      .frame(maxWidth: .infinity, alignment: .trailing) // Sağ hizalama
    }
    .padding() // İçerik etrafına boşluk
    .frame(maxWidth: .infinity) // Ekranı tamamen kaplasın
  }

  
  private var dailyWeatherView: some View {
    ScrollView(.horizontal,showsIndicators: false) {
      HStack(spacing: 16) {
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
      .frame(height: 300)
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

// CardView bileşeni
struct CardView<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .padding() // İçerik için boşluk
      .frame(maxWidth: .infinity) // Ekranın tamamını kaplasın
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(.blue).opacity(0.1)
          .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
      )
      .padding(16)
  }
}

struct DailyWeatherView: View {
  let time: String
  let icon: String

  var body: some View {
    VStack {
      Image(icon)
        .resizable()
        .frame(width: 30, height: 30)
      Text(time)
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
