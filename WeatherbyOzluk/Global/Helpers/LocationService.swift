import CoreLocation

final class LocationService: NSObject, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  private var locationCallback: ((CLLocation?, String?) -> Void)?

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
  }

  func requestLocation(callback: @escaping (CLLocation?, String?) -> Void) {
    locationCallback = callback
    checkLocationServices()
  }

  private func checkLocationServices() {
    guard CLLocationManager.locationServicesEnabled() else {
      locationCallback?(nil, "Location services are disabled")
      return
    }
    checkLocationAuthorization()
  }

  private func checkLocationAuthorization() {
    switch CLLocationManager.authorizationStatus() {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .restricted, .denied:
      locationCallback?(nil, "Location authorization is denied")
    case .authorizedAlways, .authorizedWhenInUse:
      locationManager.startUpdatingLocation()
    @unknown default:
      locationCallback?(nil, "Unknown authorization status")
    }
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    checkLocationAuthorization()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      locationCallback?(location, nil)
    } else {
      locationCallback?(nil, "Failed to get location")
    }
    locationManager.stopUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationCallback?(nil, error.localizedDescription)
    locationManager.stopUpdatingLocation()
  }

  func retrieveCityName(latitude: Double, longitude: Double, completionHandler: @escaping (CLPlacemark?, String?) -> Void) {
    let location = CLLocation(latitude: latitude, longitude: longitude)
    CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
      if let error = error {
        completionHandler(nil, error.localizedDescription)
        return
      }
      completionHandler(placemarks?.first, nil)
    }
  }
}
