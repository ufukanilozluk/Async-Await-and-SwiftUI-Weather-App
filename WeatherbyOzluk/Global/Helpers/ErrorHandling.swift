import Foundation
import UIKit


enum ErrorHandling {
  static func handleError(_ error: APIManager.APIError) {
    DispatchQueue.main.async {
      if let viewController = UIApplication.shared.windows.first?.rootViewController {
        viewController.showAlert(title: error.localizedDescription)
      }
    }
  }
}
