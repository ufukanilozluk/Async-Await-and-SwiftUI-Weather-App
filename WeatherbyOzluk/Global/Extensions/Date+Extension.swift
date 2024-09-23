import Foundation

extension Date {
  private static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.dateFormat = "HH:mm"
    return formatter
  }()
  private static let longDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM EEEE"
    return formatter
  }()
  private static let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    return formatter
  }()

  func timeIn24Hour() -> String {
    return Date.timeFormatter.string(from: self)
  }
  func dateAndTimeLong() -> String {
    return Date.longDateFormatter.string(from: self)
  }
  func dayLong() -> String {
    return Date.dayFormatter.string(from: self)
  }
}
