public struct Queue<T: Equatable>: Equatable, RandomAccessCollection {
  private let max: Int
  private var elements: [T] = []

  public init(_ max: Int) {
    self.max = max
  }

  public static func == (lhs: Queue<T>, rhs: Queue<T>) -> Bool {
    lhs.elements == rhs.elements
  }

  public var startIndex: Int {
    elements.startIndex
  }

  public var endIndex: Int {
    elements.endIndex
  }

  public func index(after i: Index) -> Int {
    elements.index(after: i)
  }

  public subscript(position: Int) -> T {
    elements[position]
  }

  public mutating func enqueue(_ value: T) {
    elements.append(value)
    if elements.count > max { dequeue() }
  }

  public mutating func dequeue() {
    guard !elements.isEmpty else { return }
    elements.removeFirst()
  }
}
