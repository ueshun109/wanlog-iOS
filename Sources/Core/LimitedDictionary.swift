public struct LimitedDictionary<T: Hashable, U: Equatable>: Equatable {
  private let max: Int
  private var elements: [T: U]

  public init(_ max: Int, elements: [T: U] = [:]) {
    self.max = max

    if elements.count <= max {
      self.elements = elements
    } else {
      let from = max
      let to = elements.count - 1
      var tmp = elements

      let removingKeys = Array(elements.keys)[from..<to]
      for key in removingKeys {
        tmp.removeValue(forKey: key)
      }
      self.elements = tmp
    }
  }

  public subscript(key: T) -> U? {
    get {
      elements[key]
    }
    set {
      let keys = elements.keys
      if keys.count < max || keys.contains(key) {
        elements[key] = newValue
      }
    }
  }

  public var count: Int {
    elements.count
  }

  public mutating func removeValue(forKey: T) {
    elements.removeValue(forKey: forKey)
  }
}
