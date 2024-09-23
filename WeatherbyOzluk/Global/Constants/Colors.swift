import Foundation
import UIKit

enum Colors {
  // Colors
  static let weatherPurpleLight = UIColor.color(120, 6, 245)
  static let weatherPurpleDark = UIColor.color(174, 13, 255)
  static let iosCaseLightGray = UIColor.color(247, 247, 250)
  static let grayDarkMode = UIColor.color(205, 202, 205)
  static let grayLightMode = UIColor.color(76, 82, 100)
  static let lightGrayDarkMode = UIColor.color(227, 225, 220)
  static let lightGrayLightMode = UIColor.color(50, 53, 64)
  static let alpha = UIColor.color(0, 0, 0, 0)

  // Dynamic Colors for Dark/Light Mode
  static var tint: UIColor {
    UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark ? weatherPurpleDark : weatherPurpleLight
    }
  }

  static var segmentedControlSelectedState: UIColor {
    UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark ? .black : .white
    }
  }

  static var segmentedControlNormalState: UIColor {
    UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
  }

  static var customLightGray: UIColor {
    UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark ? lightGrayDarkMode : lightGrayLightMode
    }
  }

  static var customGray: UIColor {
    UIColor { traitCollection in
      traitCollection.userInterfaceStyle == .dark ? grayDarkMode : grayLightMode
    }
  }
}
