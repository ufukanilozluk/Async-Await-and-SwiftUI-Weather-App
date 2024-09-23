import Network
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if let rootViewController = window?.rootViewController {
      APIManager.shared.netWorkConnectivityCheck(onViewController: rootViewController)
      KeychainHelper.saveApiKey("54bfbfe4aa755c3b005fded2b0741fa5", forKey: "openweather")
      KeychainHelper.saveApiKey("ViMALGnwtd6ZwguzkrnCM7phryDuVKY3", forKey: "accuweather")
    }
    return true
  }
}
