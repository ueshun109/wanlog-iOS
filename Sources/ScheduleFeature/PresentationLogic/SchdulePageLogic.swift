import Foundation
import SharedModels

func contains(_ schedules: [Schedule]) -> Bool {
  !schedules.filter { $0.complete }.isEmpty
}

func toString(_ date: Date, formatter: DateFormatter) -> String {
  formatter.string(from: date)
}
