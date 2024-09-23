import UIKit
import OSLog

final class HomeViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet private var mainStackView: UIStackView!
  @IBOutlet private var emptyView: UIView!
  @IBOutlet private var scrollViewAnasayfa: UIScrollView!
  @IBOutlet private var dailyWeatherCV: UICollectionView!
  @IBOutlet private var weeklyWeatherTV: UITableView!
  @IBOutlet private var lblTemperature: UILabel!
  @IBOutlet private var imgWeatherMain: UIImageView!
  @IBOutlet private var lblDescription: UILabel!
  @IBOutlet private var lblDate: UILabel!
  @IBOutlet private var lblVisibility: UILabel!
  @IBOutlet private var lblWind: UILabel!
  @IBOutlet private var lblHumidity: UILabel!
  @IBOutlet private var lblPressure: UILabel!
  @IBOutlet private var welcomeAnimationView: UIView!

  // MARK: - Properties
  private lazy var refreshControl = UIRefreshControl()
  private var segmentedControl: UISegmentedControl?
  private var dataWeather: [Forecast.Weather]?
  private var weeklyWeather: ForecastWeekly?
  private let spacing: CGFloat = 4.0
  private var selectedCity: Location?
  private let viewModel = ForecastViewModel(service: ForecastService())
  private var times: [String] = []
  private var mins: [String] = []
  private var maxs: [String] = []
  private var days: [String] = []

  // MARK: - Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    if #available(iOS 14.0, *) {
      Logger.api.notice("Sample Comment")
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Task {
      await updateHome()
    }
  }

  // MARK: - UI Configuration
  private func configureUI() {
    configureTableView()
    configureCollectionView()
    configureRefreshControl()
    configureSegmentedControl()
  }

  private func configureTableView() {
    weeklyWeatherTV.dataSource = self
    weeklyWeatherTV.delegate = self
    weeklyWeatherTV.estimatedRowHeight = 50
  }

  private func configureCollectionView() {
    dailyWeatherCV.delegate = self
    dailyWeatherCV.dataSource = self
    if let layout = dailyWeatherCV.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.scrollDirection = .horizontal
    }
  }

  private func configureRefreshControl() {
    refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    scrollViewAnasayfa.addSubview(refreshControl)
  }

  private func configureSegmentedControl() {
    let items = GlobalSettings.selectedCities.map { $0.localizedName.replacingOccurrences(of: " Province", with: "") }
    let segmentedControl = UISegmentedControl(items: items)
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.backgroundColor = Colors.iosCaseLightGray
    segmentedControl.addTarget(self, action: #selector(segmentedValueChanged(_:)), for: .valueChanged)
    mainStackView.insertArrangedSubview(segmentedControl, at: 0)
    let attributes = [NSAttributedString.Key.foregroundColor: Colors.segmentedControlNormalState]
    let attributesSelected = [NSAttributedString.Key.foregroundColor: Colors.segmentedControlSelectedState]
    segmentedControl.setTitleTextAttributes(attributes, for: .normal)
    segmentedControl.setTitleTextAttributes(attributesSelected, for: .selected)
    segmentedControl.backgroundColor = Colors.segmentedControlSelectedState
    segmentedControl.selectedSegmentTintColor = Colors.tint
    self.segmentedControl = segmentedControl
  }

  // MARK: - Data Handling
  private func reloadCollectionViewData() {
    dailyWeatherCV.reloadData()
  }

  private func reloadTableViewData() {
    weeklyWeatherTV.reloadData()
  }

  @MainActor
  private func bind() {
    self.dataWeather = viewModel.weatherData
    self.weeklyWeather = viewModel.weeklyWeatherData
    self.times = viewModel.times
    self.mins = viewModel.mins
    self.maxs = viewModel.maxs
    self.days = viewModel.days
    self.imgWeatherMain.image = viewModel.bigIcon
    self.lblDate.text = viewModel.date
    self.lblTemperature.text = viewModel.temperature
    self.lblDescription.text = viewModel.description
    self.lblHumidity.text  = viewModel.humidity
    self.lblPressure.text = viewModel.pressure
    self.lblVisibility.text = viewModel.visibility
    self.lblWind.text = viewModel.wind
    self.dailyWeatherCV.reloadData()
    self.weeklyWeatherTV.reloadData()
  }
  
  @MainActor
  private func fetchData(for city: Location) async {
    self.view.showSpinner()
    Task {
      do {
        try await viewModel.getForecast(city: city)
        bind()
      } catch let error as APIManager.APIError{
        self.showAlert(title: error.localizedDescription, alertType: .error)
      }
    }
    self.view.removeSpinner()
  }

  // MARK: - UI Updates
  private func showEmptyView() {
    view.addSubview(emptyView)
    view.startAnimation(jsonFile: "welcome-page", onView: welcomeAnimationView)
    emptyView.center = view.center
    scrollViewAnasayfa.isHidden = true
  }

  private func updateSegmentedControlItems() {
    if GlobalSettings.shouldUpdateSegments {
      let items = GlobalSettings.selectedCities.map {
        $0.localizedName.replacingOccurrences(of: " Province", with: "")
      }
      segmentedControl?.removeAllSegments()
      items.enumerated().forEach { index, item in
        segmentedControl?.insertSegment(withTitle: item, at: index, animated: false)
      }
      segmentedControl?.selectedSegmentIndex = 0
      GlobalSettings.shouldUpdateSegments = false
    }
  }

  private func fetchDataForSelectedCity() {
    if let selectedSegmentIndex = segmentedControl?.selectedSegmentIndex {
      let selectedCity = GlobalSettings.selectedCities[selectedSegmentIndex]
      self.selectedCity = selectedCity
      Task {
        await fetchData(for: selectedCity)
      }
    }
  }

  @objc private func segmentedValueChanged(_ segmentedControl: UISegmentedControl) {
    let selectedCity = GlobalSettings.selectedCities[segmentedControl.selectedSegmentIndex]
    self.selectedCity = selectedCity
    Task {
      await fetchData(for: selectedCity)
    }
  }

  @objc private func didPullToRefresh() {
    guard let selectedCity = selectedCity else { return }
    Task {
      await fetchData(for: selectedCity)
    }
  }

  private func updateHome() async {
    GlobalSettings.selectedCities = UserDefaultsHelper.getCities()
    guard !GlobalSettings.selectedCities.isEmpty else {
      showEmptyView()
      return
    }
    emptyView.removeFromSuperview()
    scrollViewAnasayfa.isHidden = false
    if segmentedControl != nil {
      updateSegmentedControlItems()
    } else {
      configureSegmentedControl()
    }
    fetchDataForSelectedCity()
  }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return weeklyWeather?.daily.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: HomeWeeklyWeatherTableviewCell.reuseIdentifier,
      for: indexPath
    )
    if let cell = cell as? HomeWeeklyWeatherTableviewCell,
      let rowData = weeklyWeather?.daily[indexPath.row],
      let imageName = rowData.weather.first?.icon,
      let image = UIImage(named: imageName) {
        cell.set(image: image, maxTemp: maxs[indexPath.row], minTemp: mins[indexPath.row], day: days[indexPath.row])
        return cell
    }
    // Return default cell if configuration fails
    return cell
  }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataWeather?.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: HomeDailyWeatherCollectionViewCell.reuseIdentifier,
      for: indexPath
    )
    if let cell = cell as? HomeDailyWeatherCollectionViewCell {
      if let rowData = dataWeather?[indexPath.row],
        let image = UIImage(named: rowData.weather[0].icon) {
        cell.set(time: times[indexPath.row], image: image)
      }
    }
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let totalWidth = collectionView.frame.width
    let cellWidth = (totalWidth - spacing) / 3
    return CGSize(width: cellWidth, height: cellWidth)
  }
}
