import Foundation

extension String {
  func firstCharLowercased() -> String {
    prefix(1).lowercased() + dropFirst()
  }
}
