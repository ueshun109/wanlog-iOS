import UIKit

public extension UIImage {
  /// Verify if it exceeds 1KB
  /// - Parameter mb: Kilobyte
  /// - Returns: Return `true` if the specified size is exceeded
  func exceed(_ byte: Int) -> Bool {
    let data = self.jpegData(compressionQuality: 1)!
    logger.debug(message: data.count)
    return data.count > byte
  }

  /// Resize image
  /// - Parameter size: Size you want to resize
  /// - Returns: Resized `UIImage`
  func resize(to byte: Int) -> Data {
    let target = self
    var compressQuality: CGFloat = 1
    var imageSize = self.jpegData(compressionQuality: 1)!.count
    while imageSize > byte {
      compressQuality -= 0.1
      imageSize = jpegData(compressionQuality: compressQuality)!.count
      logger.debug(message: imageSize)
    }
    return target.jpegData(compressionQuality: compressQuality)!
//
//
//
//
//    var resizedSize: CGSize
//
//    if self.size.width < self.size.height {
//      let aspectScale = self.size.width / self.size.height
//      logger.debug(message: self.size.width)
//      logger.debug(message: self.size.height)
//      resizedSize = CGSize(width: size * aspectScale, height: size)
//    } else {
//      let aspectScale = self.size.height / self.size.width
//      resizedSize = CGSize(width: size, height: size * aspectScale)
//    }
//    logger.debug(message: resizedSize)
//    let data = UIGraphicsImageRenderer(size: resizedSize).pngData { _ in
//      draw(in: .init(origin: .zero, size: resizedSize))
//    }
//    logger.debug(message: Double(data.count) / (1024 * 1024))
//    return data
  }
}
