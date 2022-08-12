import Core
import Foundation
import FirebaseFirestore
import SharedModels

@MainActor
public class CompleteState: ObservableObject {
  public typealias ID = String
  private let db = Firestore.firestore()
  @Published public private(set) var completes: [ID: Schedule] = [:]

  public init() {}

  public func save() async {
    let targets: [(data: Schedule, reference: DocumentReference)] = completes.values.compactMap { schedule in
      guard let id = schedule.id else { return nil }
      return (
        data: schedule,
        reference: db.schedule(
          uid: schedule.ownerId,
          dogId: schedule.dogId,
          scheduleId: id
        )
      )
    }
    do {
      try await db.updates(targets)
      completes.removeAll()
    } catch {
      logger.error(message: error)
    }
  }

  public func update(_ id: String, schedule: Schedule) {
    if schedule.complete {
      completes[id] = schedule
    } else {
      completes.removeValue(forKey: id)
    }
  }

  public func status(of id: String) -> Bool? {
    completes[id]?.complete
  }
}
