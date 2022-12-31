import Core
import XCTest

final class LimitedDictionaryTest: XCTestCase {
  var dictionary = LimitedDictionary<String, String>(3)

  override func setUp() {
    super.setUp()
    dictionary["one"] = "いち"
    dictionary["two"] = "に"
    dictionary["three"] = "さん"
  }

  func testInsert() {
    XCTContext.runActivity(named: "Max three") { _ in
      XCTAssertEqual(dictionary.count, 3)
      dictionary["four"] = "よん"
      XCTAssertEqual(dictionary.count, 3)
      XCTAssertNil(dictionary["four"])
    }
  }

  func testUpdate() {
    dictionary["one"] = "first"
    XCTAssertEqual(dictionary["one"], "first")
  }

  func testRemove() {
    dictionary.removeValue(forKey: "one")
    XCTAssertEqual(dictionary.count, 2)
    XCTAssertNil(dictionary["one"])
  }
}
