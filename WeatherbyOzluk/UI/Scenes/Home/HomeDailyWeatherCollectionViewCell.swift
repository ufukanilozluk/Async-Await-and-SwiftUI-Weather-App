import UIKit

final class HomeDailyWeatherCollectionViewCell: UICollectionViewCell {
  @IBOutlet private var frameCV: CardView!
  @IBOutlet private var imgWeather: UIImageView!
  @IBOutlet private var hour: UILabel!
  static let reuseIdentifier: String = "DailyWeatherCVCell"
  

  func set(time: String, image: UIImage) {
    hour.text = time
    imgWeather.image = image
    configImg()
  }

  func configImg() {
    imgWeather.layer.masksToBounds = true
    imgWeather.layer.cornerRadius = 12
  }
}
