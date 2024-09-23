import Foundation
import UIKit

final class CustomNavigationController: UINavigationController {
  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
    applyTheme()
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    applyTheme()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    applyTheme()
  }
  private func applyTheme() {
    let appearance = UINavigationBarAppearance()
    appearance.backgroundColor = UIColor.systemBackground
    appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
    appearance.shadowColor = nil
    if #available(iOS 15.0, *) {
      navigationBar.scrollEdgeAppearance = appearance
      navigationBar.standardAppearance = appearance
      navigationBar.compactAppearance = appearance
      navigationBar.compactScrollEdgeAppearance = appearance
    } else {
      navigationBar.standardAppearance = appearance
      navigationBar.scrollEdgeAppearance = appearance
    }
    navigationBar.tintColor = Colors.tint  // Buton ve diğer öğelerin rengi
  }
}
