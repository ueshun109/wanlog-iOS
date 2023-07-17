import Core
import FirebaseClient
import SharedModels
import Styleguide
import SwiftUI

public struct DogCreateSecondPage: View {
  @ObservedObject var dogState: DogCreateFlow
  @State private var uiState = UiState()
  private let authenticator: Authenticator = .live
  private let db = Firestore.firestore()

  public init(dog: DogCreateFlow) {
    self.dogState = dog
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: Padding.large) {
        rabiesVaccine
        combinationVaccine
        filariasisDosing
      }
      .padding(.top, Padding.medium)
    }
    .loading(
      $uiState.loading,
      showAlert: $uiState.showAlert
    )
    .background(Color.Background.primary)
    .toolbar(content: toolbarItems)
    .navigationTitle("ワンちゃん迎え入れ 2/2")
    .onChange(of: uiState.action) { new in
      guard let new else { return }
      run(action: new)
    }
    .onAppear {
      dogState.numberOfCombinationVaccine = .init(birthDate: dogState.bitrhDate)
    }
  }

  /// 💉 Combined vaccine last vaccination date
  var combinationVaccine: some View {
    Section {
      DateForm(
        date: $dogState.combinationVaccineDate,
        selectable: $uiState.hasBeenVaccinatedWithCombinationVaccine,
        showToggle: true
      )
      .padding(.horizontal, Padding.medium)
    } header: {
      sectionHeader(title: "混合ワクチン最終接種日（抗体検査日）")
        .padding(.horizontal, Padding.medium)
        .padding(.bottom, -Padding.small)
    } footer: {
      if uiState.hasBeenVaccinatedWithCombinationVaccine {
        combinationVaccineCount
          .padding(.top, -Padding.small)
      }
    }
    .animation(.default, value: uiState.hasBeenVaccinatedWithCombinationVaccine)
  }

  /// 🍪 Chips for combined vaccine count
  var combinationVaccineCount: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(Dog.Preventions.CombinationVaccine.NumberOfTimes.all) { number in
          Button {
            withAnimation {
              dogState.numberOfCombinationVaccine = number
            }
          } label: {
            Text(number.title)
          }
          .buttonStyle(.chips(selected: number == dogState.numberOfCombinationVaccine))
        }
      }
      .padding(.vertical, Padding.xxxSmall)
      .padding(.horizontal, Padding.large)
    }
  }

  /// 💊 Filariasis last dosing date
  var filariasisDosing: some View {
    Section {
      DateForm(
        date: $dogState.filariasisDosingDate,
        selectable: $uiState.hasBeenDosedWithFilariasisDrug,
        showToggle: true
      )
      .padding(.horizontal, Padding.medium)
    } header: {
      sectionHeader(title: "フィラリア最終投薬日")
        .padding(.horizontal, Padding.medium)
        .padding(.bottom, -Padding.small)
    }
    .animation(.default, value: uiState.hasBeenDosedWithFilariasisDrug)
  }

  /// 💉 Rabies vaccine last vaccination date
  var rabiesVaccine: some View {
    Section {
      DateForm(
        date: $dogState.rabiesVaccineDate,
        selectable: $uiState.hasBeenVaccinatedWithRabiesVaccine,
        showToggle: true
      )
      .padding(.horizontal, Padding.medium)
    } header: {
      sectionHeader(title: "狂犬病ワクチン最終接種日（抗体検査日）")
        .padding(.horizontal, Padding.medium)
        .padding(.bottom, -Padding.small)
    }
    .animation(.default, value: uiState.hasBeenVaccinatedWithRabiesVaccine)
  }

  /// ⛑️ Section header
  func sectionHeader(title: String, other: String? = nil) -> some View {
    HStack {
      Text(title)
      Spacer()
      if let other {
        Text(other)
      }
    }
    .font(.footnote)
    .foregroundColor(Color.Label.secondary)
    .padding(.horizontal, Padding.small)
  }

  @ToolbarContentBuilder
  /// 🧰 Toolbar items
  func toolbarItems() -> some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Button {
        uiState.action = .createDog
      } label: {
        Text("保存")
      }
      .disabled(uiState.loading == .loading)
    }
  }
}

// MARK: - UiState

extension DogCreateSecondPage {
  struct UiState {
    var action: Action?
    var hasBeenVaccinatedWithRabiesVaccine = false
    var hasBeenVaccinatedWithCombinationVaccine = false
    var hasBeenDosedWithFilariasisDrug = false
    var loading: Loading = .idle
    var showAlert: Bool = false
  }
}

// MARK: - Action

extension DogCreateSecondPage {
  enum Action: Equatable {
    case createDog
    case createTodo(docRef: DocumentReference)
    case updateIcon(dog: Dog, docRef: DocumentReference)
  }

  func run(action: Action) {
    switch action {
    case .createDog:
      Task {
        guard let uid = await authenticator.user()?.uid else {
          uiState.action = nil
          return
        }
        withAnimation {
          uiState.loading = .loading
        }
        let query: Query.Dog = .all(uid: uid)
        let newDog = dogState.create(
          hasBeenVaccinatedWithCombinationVaccine: uiState.hasBeenVaccinatedWithCombinationVaccine,
          hasBeenVaccinatedWithRabiesVaccine: uiState.hasBeenVaccinatedWithRabiesVaccine,
          hasTakenHeartwormPill: uiState.hasBeenDosedWithFilariasisDrug
        )
        do {
          let docRef = try await db.set(newDog, collectionReference: query.collection())
          uiState.action = .createTodo(docRef: docRef)
        } catch {
          withAnimation {
            uiState.loading = .failed(error: .init(error: error))
          }
          uiState.action = nil
        }
      }

    case .createTodo(let docRef):
      Task {
        guard let uid = await authenticator.user()?.uid else {
          uiState.action = nil
          return
        }
        let dogId = docRef.documentID
        let query: Query.Todo = .perDog(uid: uid, dogId: dogId)
        let repeatYear: Todo.Interval = .everyYear
        let repeatMonth: Todo.Interval = .everyMonth

        do {
          try await withThrowingTaskGroup(of: Void.self) { group in
            if uiState.hasBeenDosedWithFilariasisDrug {
              group.addTask {
                let todo = await Todo.combinationVaccination((
                  dogId: dogId,
                  ownerId: uid,
                  expiredDate: repeatYear.date(dogState.combinationVaccineDate)
                ))
                try await db.set(todo, collectionReference: query.collection())
              }
            }

            if uiState.hasBeenDosedWithFilariasisDrug {
              group.addTask {
                let todo = await Todo.giveHeartwormPill((
                  dogId: dogId,
                  ownerId: uid,
                  expiredDate: repeatMonth.date(dogState.filariasisDosingDate)
                ))
                try await db.set(todo, collectionReference: query.collection())
              }
            }

            if uiState.hasBeenVaccinatedWithRabiesVaccine {
              group.addTask {
                let todo = await Todo.rabiesVaccination((
                  dogId: dogId,
                  ownerId: uid,
                  expiredDate: repeatYear.date(dogState.rabiesVaccineDate)
                ))
                try await db.set(todo, collectionReference: query.collection())
              }
            }
            for try await _ in group { }

            let newDog = dogState.create(
              hasBeenVaccinatedWithCombinationVaccine: uiState.hasBeenVaccinatedWithCombinationVaccine,
              hasBeenVaccinatedWithRabiesVaccine: uiState.hasBeenVaccinatedWithRabiesVaccine,
              hasTakenHeartwormPill: uiState.hasBeenDosedWithFilariasisDrug
            )
            uiState.action = .updateIcon(dog: newDog, docRef: docRef)
          }
        } catch {
          uiState.action = nil
          logger.error(message: error)
        }
      }

    case .updateIcon(let dog, let docRef):
      Task {
        defer {
          uiState.action = nil
        }
        guard let uid = await authenticator.user()?.uid else { return }
        let storageRef = Storage.storage().dogRef(uid: uid, dogId: docRef.documentID)
        guard let image = dogState.image else { return }
        do {
          let oneMB = 1024 * 1024
          if image.exceed(oneMB) {
            let data = image.resize(to: oneMB)
            try await storageRef.upload(data)
          } else if let data = image.pngData() {
            try await storageRef.upload(data)
          }
          var newDog = dog
          newDog.iconRef = storageRef.fullPath
          try await db.set(newDog, documentReference: docRef)
          withAnimation {
            uiState.loading = .loaded
          }
          dogState.dismiss = true
        } catch {
          logger.error(message: error)
        }
      }
    }
  }
}

// MARK: - Preview

struct DogCreateSecondPage_Previews: PreviewProvider {
  static var previews: some View {
    DogCreateSecondPage(dog: .init())
      .background(Color.Background.primary)
  }
}
