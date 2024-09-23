import UIKit

final class CitiesViewController: UIViewController {
  @IBOutlet private var citiesTableView: UITableView!
  private var weather: [Forecast]?
  private var selectedCities: [Location] = UserDefaultsHelper.getCities()
  private var viewModel = ForecastViewModel(service: ForecastService())
  private var degrees: [String] = []
  private var dates: [String] = []
  private var cityNames: [String] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    setConfig()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    selectedCities = UserDefaultsHelper.getCities()
    guard !selectedCities.isEmpty else {
      citiesTableView.setEmptyView(
        title: "No location Found",
        message: "Start by adding a location",
        animation: "location"
      )
      return
    }
    Task {
      await getWeatherInfo()
    }
  }

  private func updateUI() {
    view.removeSpinner()
  }

  private func getWeatherInfo() async {
    view.showSpinner()
    Task{
      do{
        try await viewModel.getForecastForAllCities()
        self.weather = viewModel.allCitiesWeatherData
        self.degrees = viewModel.degree
        self.dates = viewModel.dates
        self.cityNames = viewModel.cityNames
        DispatchQueue.main.async {
          self.updateUI()
          self.citiesTableView.reloadData()
        }
      } catch let error as APIManager.APIError{
        self.showAlert(title: error.localizedDescription, alertType: .error)
      }
    }
    
    
  }

  private func setConfig() {
    configureTableView()
    configureNavigationItems()
  }

  private func configureTableView() {
    citiesTableView.delegate = self
    citiesTableView.dataSource = self
    citiesTableView.dragDelegate = self
    citiesTableView.dropDelegate = self
    citiesTableView.dragInteractionEnabled = false
    citiesTableView.allowsSelection = false
    citiesTableView.estimatedRowHeight = 60
  }

  private func configureNavigationItems() {
    navigationItem.backBarButtonItem = UIBarButtonItem(
      title: "", style: .plain, target: nil, action: nil)
    editButtonItem.title = "Edit"
    navigationItem.leftBarButtonItem = editButtonItem
  }

  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: true)
    citiesTableView.setEditing(editing, animated: true)
    citiesTableView.dragInteractionEnabled = editing
    editButtonItem.title = isEditing ? "Done" : "Edit"
  }

  @IBAction func sehirEkle(_ sender: Any) {
    performSegue(withIdentifier: "goToAddCity", sender: nil)
  }
}

// MARK: - TableView Delegate and DataSource

extension CitiesViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard !selectedCities.isEmpty else {
      tableView.setEmptyView(title: "No location found", message: "Start by adding a location", animation: "location")
      return 0
    }
    tableView.restoreToFullTableView()
    return weather?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let weatherList = weather?[indexPath.row].list, !weatherList.isEmpty else {
      return UITableViewCell()
    }

    let hava = weatherList[0]
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: CitiesTableViewCell.reuseIdentifier,
      for: indexPath
    ) as? CitiesTableViewCell else {
      return UITableViewCell()
    }

    guard let icon = hava.weather.first?.icon, let weatherPic = UIImage(named: icon) else {
      return UITableViewCell()
    }

    let row = indexPath.row
    cell.setWeather(
      weatherPic: weatherPic,
      cityName: cityNames[row],
      degree: degrees[row],
      date: dates[row]
    )
    return cell
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return isEditing
  }

  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard var weather = weather else { return }
    let mover = weather.remove(at: sourceIndexPath.row)
    weather.insert(mover, at: destinationIndexPath.row)
    self.weather = weather
    selectedCities.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    UserDefaultsHelper.moveCity(sourceIndexPath.row, destinationIndexPath.row)
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      guard var weather = weather else { return }
      weather.remove(at: indexPath.row)
      self.weather = weather
      selectedCities.remove(at: indexPath.row)
      citiesTableView.deleteRows(at: [indexPath], with: .automatic)
      UserDefaultsHelper.removeCity(index: indexPath.row)
      GlobalSettings.shouldUpdateSegments = true
    }
  }
}

// MARK: - TableView Drag and Drop Delegate

extension CitiesViewController: UITableViewDragDelegate, UITableViewDropDelegate {
  func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    // Implementation for drop functionality if needed
  }

  func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    GlobalSettings.shouldUpdateSegments = true
    guard let weather = weather else { return [] }
    let dragItem = UIDragItem(itemProvider: NSItemProvider())
    dragItem.localObject = weather[indexPath.row]
    return [dragItem]
  }
}
