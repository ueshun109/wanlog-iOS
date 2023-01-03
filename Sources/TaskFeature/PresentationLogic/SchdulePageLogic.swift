import Foundation
import SharedModels

func contains(_ tasks: [NormalTask]) -> Bool {
  !tasks.filter { $0.complete }.isEmpty
}

func toString(_ date: Date, formatter: DateFormatter) -> String {
  formatter.string(from: date)
}
