public enum CollectionDifferenceType<T: BidirectionalCollection> where T.Element: Equatable {
  case onlyUpdated(updated: [T.Element])
  case increased(updated: [T.Element], inserted: [T.Element])
  case decreased(updated: [T.Element], removed: [T.Element])
  case noChange

  public init(before: T, after: T, max: Int = 3, min: Int = -3) {
    let diffElementsCount = after.count - before.count
    let difference = after.difference(from: before)
    switch diffElementsCount {
    case 0:
      guard !difference.isEmpty else { self = .noChange; return }
      let (_, _, updated) = Self.changed(from: difference, max: max, min: min)
      self = .onlyUpdated(updated: updated)
    case 1...max:
      let (inserted, _, updated) = Self.changed(from: difference, max: max, min: min)
      self = .increased(updated: updated, inserted: inserted)
    case min ... -1:
      let (_, removed, updated) = Self.changed(from: difference, max: max, min: min)
      self = .decreased(updated: updated, removed: removed)
    default:
      fatalError("引数で指定したmaxもしくはminの範囲外")
    }
  }

  static private func changed<T: Equatable>(
    from difference: CollectionDifference<T>,
    max: Int,
    min: Int
  ) -> (inserted: [T], removed: [T], updated: [T]) {
    var inserted: [T] = []
    var removed: [T] = []
    var updated: [T] = []

    for changed in difference {
      switch changed {
      case .insert(_, let element, _):
        inserted.append(element)
      case .remove(_, let element, _):
        removed.append(element)
      }
    }

    let count = inserted.count - removed.count
    switch count {
    case 0:
      updated = inserted
      inserted.removeAll()
      removed.removeAll()
    case 1...max:
      for _ in removed.indices {
        let element = inserted.removeFirst()
        updated.append(element)
      }
      removed.removeAll()
    case min ... -1:
      for _ in inserted.indices {
        let element = removed.removeFirst()
        updated.append(element)
      }
      inserted.removeAll()
    default:
      fatalError("Unexpected range")
    }

    return (inserted, removed, updated)
  }
}
