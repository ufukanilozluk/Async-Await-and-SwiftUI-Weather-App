import SwiftUI

struct CitiesView: View {
  @StateObject private var viewModel = ForecastViewModel(service: ForecastService())
  @State private var selectedCities: [Location] = UserDefaultsHelper.getCities()
  @State private var showAlert = false
  @State private var alertMessage = ""

  var body: some View {
    NavigationStack {
      Group {
        if selectedCities.isEmpty {
          emptyView
        } else {
          cityListView
        }
      }
      .navigationTitle("Cities")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          if !selectedCities.isEmpty {
            EditButton()
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink(destination: AddCityView()) {
            Text("Add City")
          }
        }
      }
    }
    .task {
      await loadWeatherInfo()
    }
    .alert(alertMessage, isPresented: $showAlert) {
      Button("OK", role: .cancel) {}
    }
  }

  private var emptyView: some View {
    VStack {
      Spacer()
      Text("No location found")
        .font(.title)
        .padding(.bottom, 5)
      Text("Start by adding a location")
        .font(.subheadline)
      Spacer()
    }
  }

  private var cityListView: some View {
    List {
      ForEach(Array(viewModel.allCitiesWeatherData.enumerated()), id: \.offset) { index, forecast in
        if !forecast.list.isEmpty {
          let weatherList = forecast.list
          let hava = weatherList[0]
          if let icon = hava.weather.first?.icon, let weatherPic = UIImage(named: icon) {
            CityRow(
              weatherPic: weatherPic,
              cityName: viewModel.cityNames[index],
              degree: viewModel.degree[index],
              date: viewModel.dates[index]
            )
          }
        }
      }
      .onDelete(perform: deleteCity)
      .onMove(perform: moveCity)
    }
  }

  private func loadWeatherInfo() async {
    do {
      try await viewModel.getForecastForAllCities()
    } catch let error as APIManager.APIError {
      alertMessage = error.localizedDescription
      showAlert = true
    } catch {
      alertMessage = "An unexpected error occurred: \(error.localizedDescription)"
      showAlert = true
    }
  }

  private func deleteCity(at offsets: IndexSet) {
    selectedCities.remove(atOffsets: offsets)
    UserDefaultsHelper.removeCity(index: offsets.first ?? 0)
  }

  private func moveCity(from source: IndexSet, to destination: Int) {
    selectedCities.move(fromOffsets: source, toOffset: destination)
    UserDefaultsHelper.moveCity(source.first ?? 0, destination)
  }
}

struct CityRow: View {
  let weatherPic: UIImage
  let cityName: String
  let degree: String
  let date: String

  var body: some View {
    HStack {
      Image(uiImage: weatherPic)
        .resizable()
        .frame(width: 40, height: 40)
      VStack(alignment: .leading) {
        Text(cityName).font(.headline)
        Text("\(degree)° - \(date)").font(.subheadline).foregroundColor(.gray)
      }
    }
  }
}
