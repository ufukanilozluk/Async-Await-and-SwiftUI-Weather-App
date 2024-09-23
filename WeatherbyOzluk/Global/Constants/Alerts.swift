import Foundation

struct Alerts {
  var alertType: AlertType
  var alertTitle: String
}

extension Alerts {
  enum AlertType {
    case warning
    case error
    case success
    case info
  }
}

enum CustomAlerts {
  static let sameCity = Alerts(alertType: .info, alertTitle: "Already Added")
  static let added = Alerts(alertType: .success, alertTitle: "Added")
  static let internetNotConnected = Alerts(alertType: .error, alertTitle: "Internet Not Connected")
  static let internetConnected = Alerts(alertType: .success, alertTitle: "Internet Reconnected")
}
