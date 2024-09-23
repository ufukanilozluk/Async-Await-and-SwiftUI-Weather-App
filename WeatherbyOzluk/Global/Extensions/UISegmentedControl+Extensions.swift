import UIKit

extension UISegmentedControl {
  /// Segments atamak için
  func replaceSegments(with segments: [String]) {
    // Tüm segmentleri kaldır
    removeAllSegments()
    // Yeni segmentleri ekle
    for (index, segment) in segments.enumerated() {
      insertSegment(withTitle: segment, at: index, animated: false)
    }
  }
}
