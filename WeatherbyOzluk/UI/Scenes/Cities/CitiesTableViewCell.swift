import UIKit

final class CitiesTableViewCell: UITableViewCell {
  @IBOutlet private var degreeLabel: UILabel!
  @IBOutlet private var dateLabel: UILabel!
  @IBOutlet private var cityNameLabel: UILabel!
  @IBOutlet private var weatherPicImageView: UIImageView!

  static let reuseIdentifier: String = "CitiesTableViewCell"

  func setWeather(weatherPic: UIImage, cityName: String, degree: String, date: String) {
    cityNameLabel.text = cityName
    degreeLabel.text = degree
    weatherPicImageView.image = weatherPic
    dateLabel.text = date
  }
}
