import Core
import Foundation
import FirebaseClient
import SharedModels

@MainActor
public class CompleteState: ObservableObject {
  public typealias ID = String
  private let db = Firestore.firestore()
  @Published public private(set) var completes: [ID: NormalTask] = [:]

  public init() {}

  public func contains(_ id: ID) -> Bool {
    completes.contains(where: { $0.key == id })
  }

  public func save() async {
    let targets: [(data: NormalTask, reference: DocumentReference)] = completes.values.compactMap { task in
      guard let id = task.id else { return nil }
      let query: Query.NormalTask = .one(uid: task.ownerId, dogId: task.dogId, taskId: id)
      return (
        data: task,
        reference: query.document()
      )
    }
    do {
      try await db.updates(targets)
      completes.removeAll()
    } catch {
      logger.error(message: error)
    }
  }

  public func update(_ id: String, task: NormalTask) {
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
    logger.debug(message: task.complete)
    if task.complete {
      completes[id] = task
    } else {
      completes.removeValue(forKey: id)
    }
  }

  /// Change a schedule to incomplete if schedue is complete.
  /// - Parameter schedule: `Schedule`
  public func toIncomplete(_ task: NormalTask) async throws {
    guard task.complete, let id = task.id else { return }
    let query: Query.NormalTask = .one(uid: task.ownerId, dogId: task.dogId, taskId: id)
    var new = task
    new.complete = false
    try await db.set(new, documentReference: query.document())
  }

  public func status(of id: String) -> Bool? {
    completes[id]?.complete
  }
}
