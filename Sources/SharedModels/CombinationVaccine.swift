import Foundation

/// A vaccine that can prevent multiple diseases
public struct CombinationVaccine {
  /// Last vaccination date
  public var lastVaccinationDate: Date?
  /// Number of vaccinations
  public var numberOfCombinationVaccinations: NumberOfTimes?

  ///  Create new instance.
  /// - Parameters:
  ///   - lastVaccinationDate: Last vaccination date.  Nil if never vaccinated.
  ///   - numberOfCombinationVaccinations: Number of vaccinations
  public init(
    lastVaccinationDate: Date? = nil,
    numberOfCombinationVaccinations: NumberOfTimes? = nil
  ) {
    self.lastVaccinationDate = lastVaccinationDate
    self.numberOfCombinationVaccinations = numberOfCombinationVaccinations
  }

  /// Determine the next scheduled vaccination date.
  /// - Parameters:
  ///   - calendar: `Calendar`
  ///   - birthDate: dog birth date
  /// - Returns: Scheduled date of next vaccination.
  public func nextVaccinationDate(
    calendar: Calendar = .current,
    birthDate: Date
  ) -> Date? {
    guard let lastVaccinationDate, let numberOfCombinationVaccinations else {
      let eightWeeksLater = calendar.date(byAdding: .weekOfYear, value: 8, to: birthDate)
      return eightWeeksLater
    }

    switch numberOfCombinationVaccinations {
    case .first, .second:
      let fourWeeksLater = calendar.date(byAdding: .weekOfYear, value: 4, to: lastVaccinationDate)
      return fourWeeksLater
    case .third, .moreThan:
      let oneYearLater = calendar.date(byAdding: .year, value: 1, to: lastVaccinationDate)
      return oneYearLater
    default:
      return nil
    }
  }
}

public extension CombinationVaccine {
  /// Number of combination vaccinations
  struct NumberOfTimes: Identifiable, Equatable {
    /// Id
    public var id: String { title }
    /// Title
    public var title: String
    /// Vaccination period according to the number of times.
    public var periodWeek: Range<Int>

    private init(title: String, periodWeek: Range<Int>) {
      self.title = title
      self.periodWeek = periodWeek
    }

    /// Predicate the number of vaccinations from weeks of age.
    /// - Parameter weekOfAge: DateComponents representing weeks of age.
    public init?(weekOfAge: DateComponents) {
      guard let weekOfAge = weekOfAge.weekOfYear else { return nil }
      switch weekOfAge {
      case NumberOfTimes.first.periodWeek:
        self = .first
      case NumberOfTimes.second.periodWeek:
        self = .second
      case NumberOfTimes.third.periodWeek:
        self = .third
      case NumberOfTimes.moreThan.periodWeek:
        self = .moreThan
      default:
        return nil
      }
    }

    public static let all: [Self] = [.first, .second, .third, .moreThan]
    public static let first: Self = .init(title: "1回目", periodWeek: 8..<12)
    public static let second: Self = .init(title: "2回目", periodWeek: 12..<16)
    public static let third: Self = .init(title: "3回目", periodWeek: 16..<20)
    public static let moreThan: Self = .init(title: "4回目以上", periodWeek: 20..<Int.max)
  }
}
