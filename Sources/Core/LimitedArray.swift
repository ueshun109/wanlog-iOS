public struct LimitedArray<T: Equatable>: Equatable {
  private let max: Int
  private var elements: [T]

  public init(_ max: Int, elements: [T] = []) {
    self.max = max

    if elements.count <= max {
      self.elements = elements
    } else {
      self.elements = Array(elements[0..<max])
    }
  }

  @discardableResult
  public mutating func append(_ value: T) -> Bool {
    if elements.count < max {
      elements.append(value)
      return true
    } else {
      logger.error(message: "Appendable element count is \(max)")
      return false
    }
  }

  @discardableResult
  public mutating func remove(at index: Int) -> Bool {
    guard index < elements.count else {
      logger.error(message: "Index out of range.")
      return false
    }
    elements.remove(at: index)
    return true
  }

  @discardableResult
  public mutating func replace(_ value: T, at index: Int) -> Bool {
    guard index < elements.count else {
      logger.error(message: "Index out of range.")
      return false
    }
    elements[index] = value
    return true
  }

  public func toArray() -> [T] { elements }
}

// MARK: - RandomAccessCollection

extension LimitedArray: RandomAccessCollection {
  public var startIndex: Int {
    elements.startIndex
  }

  public var endIndex: Int {
    elements.endIndex
  }

  public func index(after i: Int) -> Int {
    elements.index(after: i)
  }
}

// MARK: - MutableCollection

extension LimitedArray: MutableCollection {
  public subscript(position: Int) -> T {
    get {
      elements[position]
    }
    set {
      replace(newValue, at: position)
    }
  }

  public subscript(bounds: Range<Int>) -> ArraySlice<T> {
    get {
      elements[bounds]
    }
    set {
      newValue.enumerated().forEach {
        self[$0] = $1
      }
    }
  }
}
