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

  public func contains(_ id: ID) -> Bool {
    completes.contains(where: { $0.key == id })
  }

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
//    guard !schedule.complete else {
//      toIncomplete(schedule)
//      return
//    }
//    let existed = completes.contains(where: { scheduleId, _ in
//      scheduleId == id
//    })
//    if existed {
//      completes.removeValue(forKey: id)
//    } else {
//      completes[id] = schedule
//    }
    logger.debug(message: schedule.complete)
    if schedule.complete {
      completes[id] = schedule
    } else {
      completes.removeValue(forKey: id)
    }
  }

  /// Change a schedule to incomplete if schedue is complete.
  /// - Parameter schedule: `Schedule`
  public func toIncomplete(_ schedule: Schedule) async throws {
    guard schedule.complete, let id = schedule.id else { return }
    let ref = db.schedule(uid: schedule.ownerId, dogId: schedule.dogId, scheduleId: id)
    var new = schedule
    new.complete = false
    try await db.set(data: new, reference: ref)
  }

  public func status(of id: String) -> Bool? {
    completes[id]?.complete
  }
}
