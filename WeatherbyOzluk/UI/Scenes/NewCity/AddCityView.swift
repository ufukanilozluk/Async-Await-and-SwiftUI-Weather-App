import SwiftUI
import CoreLocation

struct AddCityView: View {
    @StateObject private var viewModel = CityViewModel(service: CityService())
    @State private var searchText = ""
    @State private var cities: [Location] = []
    @State private var cityNames: [String] = []
    @State private var showAlert = false
    @State private var alertTitle = ""
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .onChange(of: searchText) { newValue in
                    if newValue.count >= 3 {
                        Task {
                            await filterContentForSearchText(newValue)
                        }
                    } else {
                        cities.removeAll()
                    }
                }
            
            if cities.isEmpty && searchText.count > 2 {
                EmptyView(animationName: "not-found", title: "Location Not Found", message: "Try something different")
            } else {
                List(cities, id: \.localizedName) { city in
                    CitiesToAddRow(city: city.localizedName) {
                        Task {
                            await addCity(city)
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle))
        }
    }
    
  private func filterContentForSearchText(_ searchText: String) async {
      do {
          // viewModel'in async fonksiyonunu çağır
          try await viewModel.findCity(query: searchText)

          // UI'yi güncelle
          self.cities = viewModel.locationSearchData
          self.cityNames = viewModel.cityNames
      } catch let apiError as APIManager.APIError {
          // APIManager hatalarını yakala ve kullanıcıya göster
          self.alertTitle = apiError.localizedDescription
          self.showAlert = true
      } catch {
          // Diğer tüm hataları yakala ve kullanıcıya göster
          self.alertTitle = "An unexpected error occurred: \(error.localizedDescription)"
          self.showAlert = true
      }
  }

    
    private func addCity(_ city: Location) async {
        let citiesArray = UserDefaultsHelper.getCities()
        if citiesArray.contains(where: { $0.localizedName == city.localizedName }) {
            self.alertTitle = CustomAlerts.sameCity.alertTitle
            self.showAlert = true
        } else {
            let locations = try? await viewModel.findCoordinate(query: city.localizedName)
            guard let location = locations?.first else { return }
            handleCityAdded(location)
        }
    }
    
    private func handleCityAdded(_ location: Location) {
        UserDefaultsHelper.saveCity(city: location)
        self.alertTitle = CustomAlerts.added.alertTitle
        self.showAlert = true
        GlobalSettings.shouldUpdateSegments = true
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}

struct CitiesToAddRow: View {
    var city: String
    var addCityAction: () -> Void

    var body: some View {
        HStack {
            Text(city)
            Spacer()
            Button(action: addCityAction) {
                Image(systemName: "plus.circle")
            }
        }
        .padding()
    }
}

struct EmptyView: View {
    var animationName: String
    var title: String
    var message: String
    
    var body: some View {
        VStack {
            // Burada animasyon eklemek için Lottie gibi bir kütüphane kullanılabilir
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)
            
            Text(title)
                .font(.headline)
                .padding(.bottom, 10)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}
