import UIKit

extension UITableView {
  func setEmptyView(title: String, message: String, image: UIImage? = nil, animation: String? = nil) {
    let emptyView = UIView()
    let stackView: UIStackView = {
      let stackView = UIStackView()
      stackView.translatesAutoresizingMaskIntoConstraints = false
      stackView.axis = .vertical
      stackView.distribution = .equalSpacing
      stackView.alignment = .center
      stackView.spacing = 10
      return stackView
    }()
    let titleLabel: UILabel = {
      let label = UILabel()
      label.text = title
      label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
      label.textColor = Colors.customGray
      label.textAlignment = .center
      return label
    }()
    let messageLabel: UILabel = {
      let label = UILabel()
      label.text = message
      label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
      label.textColor = Colors.customLightGray
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
    } else if let animation = animation {
      let animationView: UIView = {
        let view = UIView()
        NSLayoutConstraint.activate([
          view.widthAnchor.constraint(equalToConstant: 100),
          view.heightAnchor.constraint(equalToConstant: 100)
        ])
        self.startAnimation(jsonFile: animation, onView: view)
        return view
      }()
      stackView.addArrangedSubview(animationView)
    }
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(messageLabel)
    emptyView.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
    ])
    backgroundView = emptyView
    separatorStyle = .none
  }

  func restoreToFullTableView() {
    backgroundView = nil
    separatorStyle = .singleLine
  }
}
