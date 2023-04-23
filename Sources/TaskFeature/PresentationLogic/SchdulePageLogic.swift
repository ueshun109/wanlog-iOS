import Foundation
import SharedModels

func contains(_ todos: [Todo]) -> Bool {
  !todos.filter { $0.complete }.isEmpty
}

func toString(_ date: Date, formatter: DateFormatter) -> String {
  formatter.string(from: date)
}
