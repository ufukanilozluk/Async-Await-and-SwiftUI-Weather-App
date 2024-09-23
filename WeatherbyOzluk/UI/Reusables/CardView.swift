import Foundation
import UIKit

@IBDesignable
final class CardView: UIView {
  @IBInspectable private var cornerRadius: CGFloat = 5
  @IBInspectable private var shadowColor: UIColor? = UIColor.black
  @IBInspectable private var borderColor: UIColor? = UIColor.black
  @IBInspectable private var shadowOffsetWidth: Int = 0
  @IBInspectable private var shadowOffsetHeight: Int = 1
  @IBInspectable private var shadowOpacity: Float = 0.2
  override func layoutSubviews() {
    layer.cornerRadius = cornerRadius
    layer.shadowColor = shadowColor?.cgColor
    layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
    updateShadowPath()
    layer.shadowOpacity = shadowOpacity
    layer.borderColor = borderColor?.cgColor
  }
  private func updateShadowPath() {
    let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
    layer.shadowPath = shadowPath.cgPath
  }
}
