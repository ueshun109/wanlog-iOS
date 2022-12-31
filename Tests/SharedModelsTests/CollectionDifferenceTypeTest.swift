import SharedModels
import XCTest

final class CollectionDifferenceTypeTest: XCTestCase {
  func testNoChange() {
    let before = [1, 2, 3]
    let after = [1, 2, 3]
    let diff = CollectionDifferenceType(before: before, after: after)
    switch diff {
    case .noChange:
      XCTAssertTrue(true)
    default:
      XCTFail("expected noChange")
    }
  }

  func testOnlyUpdated() {
    XCTContext.runActivity(named: "one change") { _ in
      let before = [1, 2, 3]
      let after = [4, 2, 3]
      let diff = CollectionDifferenceType(before: before, after: after)
      switch diff {
      case .onlyUpdated(let updated):
        guard let item = updated.first, updated.count == 1 else { XCTFail("Expected one change"); return }
        XCTAssertEqual(item, 4)
      default:
        XCTFail("Expected one change")
      }
    }

    XCTContext.runActivity(named: "two change") { _ in
      let before = [1, 2, 3]
      let after = [4, 5, 3]
      let diff = CollectionDifferenceType(before: before, after: after)
      switch diff {
      case .onlyUpdated(let updated):
        guard updated.count == 2 else { XCTFail("Expected one change"); return }
        XCTAssertEqual(updated[0], 4)
        XCTAssertEqual(updated[1], 5)
      default:
        XCTFail("Expected one change")
      }
    }

    XCTContext.runActivity(named: "three change") { _ in
      let before = [1, 2, 3]
      let after = [4, 5, 6]
      let diff = CollectionDifferenceType(before: before, after: after)
      switch diff {
      case .onlyUpdated(let updated):
        guard updated.count == 3 else { XCTFail("Expected one change"); return }
        XCTAssertEqual(updated[0], 4)
        XCTAssertEqual(updated[1], 5)
        XCTAssertEqual(updated[2], 6)
      default:
        XCTFail("Expected one change")
      }
    }
  }

  func testIncreased() {
    XCTContext.runActivity(named: "only inserted") { _ in
      XCTContext.runActivity(named: "one inserted") { _ in
        let before: [Int] = []
        let after = [1]
        let diff = CollectionDifferenceType(before: before, after: after)
        switch diff {
        case .increased(_, let inserted):
          guard inserted.count == 1 else { XCTFail("Expected three"); return }
          XCTAssertEqual(inserted[0], 1)
        default:
          XCTFail("Expected three")
        }
      }
      XCTContext.runActivity(named: "three inserted") { _ in
        let before: [Int] = []
        let after = [1, 2, 3]
        let diff = CollectionDifferenceType(before: before, after: after)
        switch diff {
        case .increased(_, let inserted):
          guard inserted.count == 3 else { XCTFail("Expected three"); return }
          XCTAssertEqual(inserted[0], 1)
          XCTAssertEqual(inserted[1], 2)
          XCTAssertEqual(inserted[2], 3)
        default:
          XCTFail("Expected three")
        }
      }
    }

    XCTContext.runActivity(named: "insert and update") { _ in
      XCTContext.runActivity(named: "one insert and two update") { _ in
        let before = [1, 2]
        let after = [3, 4, 5]
        let diff = CollectionDifferenceType(before: before, after: after)
        switch diff {
        case .increased(let updated, let inserted):
          guard inserted.count == 1,
                updated.count == 2
          else { XCTFail("Expected one insert and two update"); return }
          XCTAssertEqual(inserted[0], 5)
          XCTAssertEqual(updated[0], 3)
          XCTAssertEqual(updated[1], 4)
        default:
          XCTFail("Expected three")
        }
      }

      XCTContext.runActivity(named: "two insert and one update") { _ in
        let before = [1]
        let after = [3, 4, 5]
        let diff = CollectionDifferenceType(before: before, after: after)
        switch diff {
        case .increased(let updated, let inserted):
          guard inserted.count == 2,
                updated.count == 1
          else { XCTFail("Expected two insert and one update"); return }
          XCTAssertEqual(inserted[0], 4)
          XCTAssertEqual(inserted[1], 5)
          XCTAssertEqual(updated[0], 3)
        default:
          XCTFail("Expected three")
        }
      }
    }
  }

  func testDecreased() {
    XCTContext.runActivity(named: "only decreased") { _ in
      XCTContext.runActivity(named: "one decreased") { _ in
        let before = [1]
        let after: [Int] = []
        let diff = CollectionDifferenceType(before: before, after: after)
        switch diff {
        case .decreased(_, let removed):
          guard removed.count == 1 else { XCTFail("Expected removed count is one"); return }
          XCTAssertEqual(removed[0], 1)
        default:
          XCTFail("Expected three")
        }
      }
      XCTContext.runActivity(named: "three decreased") { _ in
        let before = [1, 2, 3]
        let after: [Int] = []
        let diff = CollectionDifferenceType(before: before, after: after)
        switch diff {
        case .decreased(_, let removed):
          guard removed.count == 3 else { XCTFail("Expected three"); return }
          XCTAssertEqual(removed[0], 3)
          XCTAssertEqual(removed[1], 2)
          XCTAssertEqual(removed[2], 1)
        default:
          XCTFail("Expected three")
        }
      }
    }

    XCTContext.runActivity(named: "remove and update") { _ in
      XCTContext.runActivity(named: "one remove and two update") { _ in
        let before = [3, 4, 5]
        let after = [1, 2]
        let diff = CollectionDifferenceType(before: before, after: after)
        switch diff {
        case .decreased(let updated, let removed):
          guard removed.count == 1,
                updated.count == 2
          else { XCTFail("Expected one insert and two update"); return }
          XCTAssertEqual(removed[0], 3)
          XCTAssertEqual(updated[0], 5)
          XCTAssertEqual(updated[1], 4)
        default:
          XCTFail("Expected three")
        }
      }

      XCTContext.runActivity(named: "two remove and one update") { _ in
        let before = [3, 4, 5]
        let after = [1]
        let diff = CollectionDifferenceType(before: before, after: after)
        switch diff {
        case .decreased(let updated, let removed):
          guard removed.count == 2,
                updated.count == 1
          else { XCTFail("Expected two remove and one update"); return }
          XCTAssertEqual(removed[0], 4)
          XCTAssertEqual(removed[1], 3)
          XCTAssertEqual(updated[0], 5)
        default:
          XCTFail("Expected three")
        }
      }
    }
  }
}
