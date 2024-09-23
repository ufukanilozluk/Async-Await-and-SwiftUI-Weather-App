import Foundation
import OSLog

@available(iOS 14.0, *)
extension Logger {
  private static var subsystem: String {
    guard let identifier = Bundle.main.bundleIdentifier else {
      fatalError("Bundle identifier could not be found.")
    }
    return identifier
  }
  static let viewCycle = Logger(subsystem: subsystem, category: "ViewCycle")
  static let general = Logger(subsystem: subsystem, category: "General")
  static let api = Logger(subsystem: subsystem, category: "API")
}
