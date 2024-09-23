import UIKit

final class HomeWeeklyWeatherTableviewCell: UITableViewCell {
  @IBOutlet private var imgWeatherTV: UIImageView!
  @IBOutlet private var lblDay: UILabel!
  @IBOutlet private var lblMaxWeatherTV: UILabel!
  @IBOutlet private var lblMinWeatherTV: UILabel!
  static let reuseIdentifier = "WeeklyWeatherTVCell"

  func set(image: UIImage, maxTemp: String, minTemp: String, day: String) {
    imgWeatherTV.image = image
    lblMaxWeatherTV.text = maxTemp
    lblMinWeatherTV.text = minTemp
    lblDay.text = day
  }
}
