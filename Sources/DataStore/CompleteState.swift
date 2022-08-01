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
    let targets = completes.values
      .compactMap {
        if let id = $0.id {
          return (data: $0, reference: db.schedule(uid: $0.ownerId, dogId: $0.dogId, scheduleId: id))
        } else {
          return nil
        }
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
