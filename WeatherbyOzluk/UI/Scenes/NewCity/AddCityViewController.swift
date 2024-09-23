import UIKit
import CoreLocation

final class AddCityViewController: UIViewController {
    @IBOutlet private var citiesTableView: UITableView!

    private var cities: [Location] = []
    private let searchController = UISearchController(searchResultsController: nil)
    private let cityViewModel = CityViewModel(service: CityService())
    private var locationToAdd: [Location]?
    private var cityNames: [String] = []

    private var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }
    private var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setupBindings()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setSearchTextField()
    }

    // MARK: - Configuration Methods
    private func setConfig() {
        configureTableView()
        configureSearchController()
        setSearchTextField()
        registerForKeyboardNotifications()
    }

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            citiesTableView.contentInset = contentInsets
            citiesTableView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        citiesTableView.contentInset = contentInsets
        citiesTableView.scrollIndicatorInsets = contentInsets
    }

    private func configureTableView() {
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        citiesTableView.allowsSelection = false
        citiesTableView.estimatedRowHeight = 50
    }

    private func configureSearchController() {
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.setValue("Cancel", forKey: "cancelButtonText")
        navigationController?.navigationBar.backItem?.title = ""
    }

    private func setupBindings() {
        // We don't need Combine here anymore as we're using async/await
    }

    // MARK: - Other Methods
    private func setSearchTextField() {
        let imageView = UIImageView(image: UIImage(named: "search"))
        if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.layer.cornerRadius = 15
            searchTextField.textAlignment = .left
            searchTextField.leftView = nil
            searchTextField.placeholder = " Type minimum 3 characters"
            searchTextField.rightView = imageView
            searchTextField.rightViewMode = .always
            searchTextField.leftViewMode = .always
        }
    }

    @IBAction func getLocationIBA(_ sender: Any) {
        getLocation()
    }

    private func getLocation() {
        let locationService = LocationService()

        locationService.requestLocation { [weak self] location, error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Unable to retrieve location: \(error)", alertType: .error)
                return
            }
            guard let location = location else {
                self?.showAlert(title: "Error", message: "Unable to retrieve location.", alertType: .error)
                return
            }
            self?.retrieveCityName(from: location, using: locationService)
        }
    }

    private func retrieveCityName(from location: CLLocation, using locationService: LocationService) {
        locationService.retrieveCityName(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ) { [weak self] placeMark, error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Unable to retrieve city information: \(error)", alertType: .error)
                return
            }
            guard let placeMark = placeMark,
                  let cityName = placeMark.administrativeArea,
                  let countryName = placeMark.country else {
                self?.showAlert(title: "Error", message: "Unable to retrieve city information.", alertType: .error)
                return
            }
            self?.handleCityNameRetrieved(cityName: cityName, countryName: countryName, location: location)
        }
    }

    private func handleCityNameRetrieved(cityName: String, countryName: String, location: CLLocation) {
        let citiesArray = UserDefaultsHelper.getCities()
        if citiesArray.contains(where: { $0.localizedName == cityName }) {
            showAlert(title: CustomAlerts.sameCity.alertTitle, alertType: CustomAlerts.sameCity.alertType)
        } else {
            let geoPosition = Location.GeoPosition(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            let city = Location(
                localizedName: cityName,
                country: Location.Country(localizedName: countryName),
                geoPosition: geoPosition
            )
            UserDefaultsHelper.saveCity(city: city)
            showAlert(title: CustomAlerts.added.alertTitle, alertType: CustomAlerts.added.alertType)
            clearSearchAndReload()
            GlobalSettings.shouldUpdateSegments = true
        }
    }

    private func clearSearchAndReload() {
        searchController.searchBar.text = ""
        cities.removeAll()
        citiesTableView.reloadData()
        searchController.searchBar.endEditing(true)
    }

  private func filterContentForSearchText(_ searchText: String) {
      view.showSpinner()
      Task {
          do {
              // ViewModel'in async fonksiyonunu çağır
              try await cityViewModel.findCity(query: searchText)
              // ViewModel'in yayınlanan özelliklerine göre UI'yi güncelle
              self.cities = cityViewModel.locationSearchData
              self.cityNames = cityViewModel.cityNames
              self.citiesTableView.reloadData()
          } catch let error as APIManager.APIError {
            showAlert(title: error.localizedDescription)
          }
              // Spinner'ı kaldır
          self.view.removeSpinner()
      }
      }
  }

// MARK: - UITableViewDataSource
extension AddCityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cities.isEmpty && isFiltering, let searchText = searchController.searchBar.text, searchText.count > 2 {
            tableView.setEmptyView(title: "Location Not Found", message: "Try something different", animation: "not-found")
        } else {
            tableView.restoreToFullTableView()
        }
        return cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CitiesToAddTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CitiesToAddTableViewCell else {
            fatalError("Failed to dequeue CitiesToAddTableViewCell")
        }
        let city = cityNames[indexPath.row]
        cell.set(city: city)
        cell.addCityAction = { [weak self] in
            self?.addCity(at: indexPath, cell: cell)
        }
        return cell
    }

    private func addCity(at indexPath: IndexPath, cell: CitiesToAddTableViewCell) {
        let citiesArray = UserDefaultsHelper.getCities()
        let cityName = cities[indexPath.row].localizedName

        guard !citiesArray.contains(where: { $0.localizedName == cityName }) else {
            showAlert(title: CustomAlerts.sameCity.alertTitle, alertType: CustomAlerts.sameCity.alertType)
            cell.addButton.isEnabled = true
            return
        }

        cell.addButton.isEnabled = false
        Task {
            do {
                let locations = try await cityViewModel.findCoordinate(query: cityName)
                guard let location = locations.first else { return }
                handleCityAdded(location: location, cell: cell)
                clearSearchAndReload()
                self.view.removeSpinner()
            } catch {
                self.view.removeSpinner()
                print("Error finding coordinate: \(error)")
            }
        }
    }

    private func handleCityAdded(location: Location, cell: CitiesToAddTableViewCell) {
        showAlert(title: CustomAlerts.added.alertTitle, alertType: CustomAlerts.added.alertType)
        cell.addButton.isEnabled = true
        GlobalSettings.shouldUpdateSegments = true
        clearSearchAndReload()
        UserDefaultsHelper.saveCity(city: location)
    }
}

// MARK: - UISearchResultsUpdating
extension AddCityViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        if searchText.count >= 3 {
            filterContentForSearchText(searchText)
        } else {
            cities.removeAll()
            citiesTableView.reloadData()
        }
    }
}
