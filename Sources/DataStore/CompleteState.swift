import Core
import Foundation
import FirebaseClient
import SharedModels

@MainActor
/// Manage todo completion status.
public class CompleteState: ObservableObject {
  public typealias ID = String
  private let db = Firestore.firestore()
  @Published public private(set) var completes: [ID: Todo] = [:]

  public init() {}
}

// MARK: - Public methods

public extension CompleteState {
  /// Update status of todos related to the id
  /// - Parameter id: todo id
  /// - Returns: Return true if complete.
  func status(of id: String?) -> Bool {
    guard let id = id else { return false }
    return completes[id]?.complete ?? false
  }

  @discardableResult
  /// Change a todo to complete if todo is incomplete.
  /// - Returns: Completed todos.
  func toComplete() async throws -> [Todo] {
    let targets: [(data: Todo, reference: DocumentReference)]
    targets = completes.values.compactMap { todo in
      guard let id = todo.id else { return nil }
      let query: Query.Todo = .one(uid: todo.ownerId, dogId: todo.dogId, taskId: id)
      return (data: todo, reference: query.document())
    }
    try await db.updates(targets, removeFields: ["repeatDate": FieldValue.delete()])
    let completedTodos = completes.values
    completes.removeAll()
    return Array(completedTodos)
  }

  func update(original: Todo, updated: Todo) async throws {
    guard let id = original.id else { return }
    let completed = original.complete && !contains(id)
    if completed {
      try await toIncomplete(original)
    } else {
      updateDraftStatus(todo: updated, id: id)
    }
  }
}

// MARK: - Private methods

private extension CompleteState {
  /// Whether it is included in the provisional update status.
  /// - Parameter id: id
  /// - Returns: Return true if included.
  func contains(_ id: ID) -> Bool {
    completes.contains(where: { $0.key == id })
  }

  /// Change a schedule to incomplete if todo is complete.
  /// - Parameter schedule: `Schedule`
  func toIncomplete(_ todo: Todo) async throws {
    guard todo.complete, let id = todo.id else { return }
    let query: Query.Todo = .one(uid: todo.ownerId, dogId: todo.dogId, taskId: id)
    var new = todo
    new.complete = false
    try await db.set(new, documentReference: query.document())
  }

  /// Tentatively update completion status.
  /// - Parameters:
  ///   - todo: update target
  ///   - id: update target id
  func updateDraftStatus(todo: Todo, id: String) {
    if todo.complete {
      completes[id] = todo
    } else {
      completes.removeValue(forKey: id)
    }
  }
}
