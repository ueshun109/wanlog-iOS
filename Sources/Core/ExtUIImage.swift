import UIKit

public extension UIImage {
  /// Verify if it exceeds specified byte.
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
  }
}
