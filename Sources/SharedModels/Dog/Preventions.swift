import Foundation

extension Dog {
  /// Types of preventive drugs.
  ///
  /// We have a type that wraps Prevension because we want to treat it as a Map type in Firestore.
  public struct Preventions: Codable, Hashable {
    /// A vaccine that can prevent multiple diseases
    let combinationVaccine: CombinationVaccine
    /// Medicines to prevent heartworm disease
    let heartwormPill: HeartwormPill
    /// Vaccine to prevent rabies
    let rabiesVaccine: RabiesVaccine

    public init(
      combinationVaccine: CombinationVaccine,
      heartwormPill: HeartwormPill,
      rabiesVaccine: RabiesVaccine
    ) {
      self.combinationVaccine = combinationVaccine
      self.heartwormPill = heartwormPill
      self.rabiesVaccine = rabiesVaccine
    }

    public static let fake = Self(
      combinationVaccine: .init(latestDate: .now, number: .first),
      heartwormPill: .init(latestDate: .now),
      rabiesVaccine: .init(latestDate: .now)
    )
  }
}

// MARK: - CombinationVaccine

extension Dog.Preventions {
  /// A vaccine that can prevent multiple diseases
  public struct CombinationVaccine: Codable, Hashable {
    /// Last vaccination date
    public var latestDate: Date?
    /// Number of vaccinations
    public var number: NumberOfTimes?

    ///  Create new instance.
    /// - Parameters:
    ///   - latestDate: Last vaccination date.  Nil if never vaccinated.
    ///   - number: Number of vaccinations
    public init(
      latestDate: Date? = nil,
      number: NumberOfTimes? = nil
    ) {
      self.latestDate = latestDate
      self.number = number
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
      guard let latestDate, let number else {
        let eightWeeksLater = calendar.date(byAdding: .weekOfYear, value: 8, to: birthDate)
        return eightWeeksLater
      }

      switch number {
      case .first, .second:
        let fourWeeksLater = calendar.date(byAdding: .weekOfYear, value: 4, to: latestDate)
        return fourWeeksLater
      case .third, .moreThan:
        let oneYearLater = calendar.date(byAdding: .year, value: 1, to: latestDate)
        return oneYearLater
      default:
        return nil
      }
    }
  }
}

extension Dog.Preventions.CombinationVaccine {
  /// Number of combination vaccinations
  public struct NumberOfTimes: Identifiable, Equatable, Codable, Hashable {
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
    /// - Parameters:
    ///   - birthDate: Birth date
    ///   - now: Current date
    public init?(birthDate: Date, now: Date = .now) {
      let diffInSeconds = now.timeIntervalSince(birthDate)
      let oneWeekForSeconds: TimeInterval = 60 * 60 * 24 * 7
      let diffInWeeks = diffInSeconds / oneWeekForSeconds
      let weeks = Int(diffInWeeks)
      var components = DateComponents()
      components.weekOfYear = weeks
      self.init(weekOfAge: components)
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
    public static let moreThan: Self = .init(title: "4回目以上", periodWeek: 20..<2600)
  }
}

// MARK: - HeartwormPill

extension Dog.Preventions {
  /// Medicines to prevent heartworm disease
  public struct HeartwormPill: Codable, Hashable {
    /// The last time you gave your dog medicine
    public var latestDate: Date?

    /// Create new instance
    /// - Parameter latestDate: The last time you gave your dog medicine
    public init(latestDate: Date? = nil) {
      self.latestDate = latestDate
    }

    /// Determine the next scheduled dosing date.
    /// - Parameters:
    ///   - calendar: `Calendar`
    ///   - currentDate: current date
    /// - Returns:  Scheduled date of next dosing.
    public func nextDosingDate(
      calendar: Calendar = .current,
      currentDate: Date = .now
    ) -> Date {
      let currentMonth = calendar.component(.month, from: currentDate)
      let april = 4
      let november = 11
      let december = 12
      guard let latestDate else {
        if april...december ~= currentMonth {
          let rightNow: Date = currentDate
          return rightNow
        } else {
          let nextApril = nextApril(calendar: calendar, date: currentDate) ?? currentDate
          return nextApril
        }
      }

      let lastGivenDateMonth = calendar.component(.month, from: latestDate)
      if april...november ~= lastGivenDateMonth {
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: latestDate)
        return nextMonth ?? currentDate
      } else {
        let nextApril = nextApril(calendar: calendar, date: currentDate) ?? currentDate
        return nextApril
      }
    }

    private func nextApril(
      calendar: Calendar,
      date: Date
    ) -> Date? {
      let year = calendar.component(.year, from: date)
      let month = calendar.component(.month, from: date)
      let nextMayYear = month >= 4 ? year + 1 : year

      var dateComponents = DateComponents()
      dateComponents.year = nextMayYear
      dateComponents.month = 4
      dateComponents.day = 1
      let nextMay = calendar.date(from: dateComponents)
      return nextMay
    }
  }
}

// MARK: - RabiesVaccine

extension Dog.Preventions {
  /// Vaccine to prevent rabies
  public struct RabiesVaccine: Codable, Hashable {
    /// Last vaccination date
    public var latestDate: Date?

    /// Create new instance
    /// - Parameter latestDate: Last vaccination date. Nil if never vaccinated.
    public init(latestDate: Date? = nil) {
      self.latestDate = latestDate
    }

    /// Determine the next scheduled vaccination date.
    /// - Parameters:
    ///   - calendar: `Calendar`
    ///   - birthDate: dog birth date
    /// - Returns: Scheduled date of next vaccination.
    public func nextVaccinationDate(
      calendar: Calendar = .current,
      birthDate: Date,
      currentDate: Date = .now
    ) -> Date? {
      guard let latestDate else {
        let diff = calendar.dateComponents([.day], from: birthDate, to: currentDate)
        if let days = diff.day, days >= 91 {
          return currentDate
        } else {
          return nil
        }
      }

      let nextYear = calendar.date(byAdding: .year, value: 1, to: latestDate)
      return nextYear
    }
  }
}
