import UIKit

final class CitiesToAddTableViewCell: UITableViewCell {
  var addCityAction: (() -> Void)?
  static let reuseIdentifier: String = "AddNewCity"
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet private var cityNameLabel: UILabel!

  @IBAction func addCity(_ sender: UIButton) {
    sender.isEnabled = false
    addCityAction?()
  }
  func set(city: String) {
    cityNameLabel.text = city
  }
}
