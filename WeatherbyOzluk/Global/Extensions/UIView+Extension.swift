import UIKit
import Lottie

extension UIView {
  var width: CGFloat {
    frame.size.width
  }

  var height: CGFloat {
    frame.size.height
  }

  func addSubviews(_ views: UIView...) {
    views.forEach { addSubview($0) }
  }

  func showSpinner() {
    let dimView: UIView = {
      let view = UIView(frame: bounds)
      view.backgroundColor = UIColor(white: 0, alpha: 0.5)
      view.translatesAutoresizingMaskIntoConstraints = false
      view.tag = 999
      return view
    }()

    let spinner: UIActivityIndicatorView = {
      let spinner = UIActivityIndicatorView(style: .large)
      spinner.translatesAutoresizingMaskIntoConstraints = false
      spinner.startAnimating()
      return spinner
    }()

    dimView.addSubview(spinner)
    addSubview(dimView)

    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: dimView.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: dimView.centerYAnchor),
      dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
      dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
      dimView.topAnchor.constraint(equalTo: topAnchor),
      dimView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  func removeSpinner() {
    if let dimView = viewWithTag(999) {
      dimView.removeFromSuperview()
    }
  }

  func startAnimation(jsonFile: String, onView view: UIView) {
    removeAnimation()

    let animationView: LottieAnimationView = {
      let view = LottieAnimationView(name: jsonFile)
      view.contentMode = .scaleAspectFill
      view.loopMode = .loop
      view.animationSpeed = 0.5
      view.layer.cornerRadius = 15
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
    }()

    view.addSubview(animationView)

    NSLayoutConstraint.activate([
      animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
      animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
    ])

    animationView.play()
  }

  private func removeAnimation() {
    subviews.compactMap { $0 as? LottieAnimationView }.forEach { $0.removeFromSuperview() }
  }
}
