import UIKit

extension UIViewController {
  /// Presents an alert with the specified title and message.
  ///
  /// - Parameters:
  ///   - title: The title of the alert.
  ///   - message: The message body of the alert.
  ///   - actionTitle: The title of the action button. Default is "OK".
  ///   - completion: A closure to be executed when the action button is tapped. Default is `nil`.
  ///   - style: The style of the alert controller. Default is `.alert`.
  ///   - presentationCompletion: A closure to be executed after the alert is presented. Default is `nil`.
  ///   - alertType: The type of the alert for different styles. Default is `.info`.
  func showAlert(
    title: String,
    message: String = "",
    actionTitle: String = "OK",
    completion: (() -> Void)? = nil,
    style: UIAlertController.Style = .alert,
    presentationCompletion: (() -> Void)? = nil,
    alertType: Alerts.AlertType = .info
  ) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
    let action = UIAlertAction(title: actionTitle, style: .default) { _ in
      completion?()
    }
    switch alertType {
    case .success:
      alertController.view.tintColor = UIColor.systemGreen
      alertController.title = "✅ " + title
    case .error:
      alertController.view.tintColor = UIColor.systemRed
      alertController.title = "❌ " + title
    case .warning:
      alertController.view.tintColor = UIColor.systemYellow
      alertController.title = "⚠️ " + title
    case .info:
      alertController.view.tintColor = UIColor.systemBlue
      alertController.title = "ℹ️ " + title
    }
    alertController.addAction(action)
    DispatchQueue.main.async {
      self.present(alertController, animated: true, completion: presentationCompletion)
    }
  }

  /// Shows a toast message with the specified duration and alert type.
  ///
  /// - Parameters:
  ///   - message: The message to display in the toast.
  ///   - seconds: The duration for which the toast should be visible.
  ///   - alertType: The type of the alert for different styles. Default is `.info`.
  func showToast(message: String, seconds: Double, alertType: Alerts.AlertType = .info) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    switch alertType {
    case .warning:
      alert.view.backgroundColor = .yellow
    case .error:
      alert.view.backgroundColor = .red
    case .success:
      alert.view.backgroundColor = .green
    case .info:
      alert.view.backgroundColor = .blue
    }
    alert.view.layer.cornerRadius = 15
    self.present(alert, animated: true, completion: nil)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
      alert.dismiss(animated: true)
    }
  }

  /// Sets an empty view with the specified title, message, and optional image.
  ///
  /// - Parameters:
  ///   - title: The title of the empty view.
  ///   - message: The message body of the empty view.
  ///   - image: An optional image to display in the empty view.
  func setEmptyView(title: String, message: String, image: UIImage? = nil) {
    let emptyView = UIView(
      frame: CGRect(
        x: view.center.x,
        y: view.center.y,
        width: view.bounds.size.width,
        height: view.bounds.size.height
      )
    )
    let stackView: UIStackView = {
      let stackView = UIStackView()
      stackView.translatesAutoresizingMaskIntoConstraints = false
      stackView.axis = .vertical
      stackView.distribution = .fill
      stackView.alignment = .center
      stackView.spacing = 10
      return stackView
    }()
    let titleLabel: UILabel = {
      let label = UILabel()
      label.textColor = UIColor.black
      label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
      label.textAlignment = .center
      return label
    }()
    let messageLabel: UILabel = {
      let label = UILabel()
      label.textColor = UIColor.lightGray
      label.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
      label.textAlignment = .center
      return label
    }()

    if let image = image {
      let imageView: UIImageView = {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
      }()
      stackView.addArrangedSubview(imageView)
    }
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(messageLabel)
    emptyView.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
    ])
    titleLabel.text = title
    messageLabel.text = message
    view = emptyView
  }
}
