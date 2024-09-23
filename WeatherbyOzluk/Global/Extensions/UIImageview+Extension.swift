import UIKit

extension UIImageView {
  convenience init?(named name: String, contentMode: UIView.ContentMode = .scaleToFill) {
    guard let image = UIImage(named: name) else {
      return nil
    }
    self.init(image: image)
    self.contentMode = contentMode
    translatesAutoresizingMaskIntoConstraints = false
  }
}
