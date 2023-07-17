@testable import CertifiateFeature
import SharedModels
import XCTest

final class ValidateCertificateTest: XCTestCase {
  let dog = Dog(name: "taro", birthDate: .init(date: Date()), biologicalSex: .male, iconRef: nil, preventions: .fake)
  func testValidation() {
    XCTContext.runActivity(named: "InValid") { _ in
      XCTContext.runActivity(named: "title is empty") { _ in
        let result = validateCertificate(title: "", images: [1], dog: dog)
        XCTAssertFalse(result)
      }

      XCTContext.runActivity(named: "images is empty") { _ in
        let result = validateCertificate(title: "aaa", images: [], dog: dog)
        XCTAssertFalse(result)
      }

      XCTContext.runActivity(named: "dog is nil") { _ in
        let result = validateCertificate(title: "aaa", images: [1], dog: nil)
        XCTAssertFalse(result)
      }
    }

    XCTContext.runActivity(named: "Valid") { _ in
      let result = validateCertificate(title: "aaa", images: [1], dog: dog)
      XCTAssertTrue(result)
    }
  }
}
