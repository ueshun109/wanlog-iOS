import SharedModels
import Styleguide
import SwiftUI

public struct DogCreateSecondPage: View {
  @ObservedObject var dog: DogState
  @State private var uiState = UiState()

  public init(dog: DogState) {
    self.dog = dog
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
    .background(Color.Background.primary)
    .toolbar(content: toolbarItems)
    .navigationTitle("ワンちゃん迎い入れ 2/2")
  }

  /// 💉 Combined vaccine last vaccination date
  var combinationVaccine: some View {
    Section {
      DateForm(
        date: $dog.combinationVaccineDate,
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
        ForEach(CombinationVaccineFrequency.all) { frequency in
          Button {
            withAnimation {
              dog.combinationVaccineFrequency = frequency
            }
          } label: {
            Text(frequency.title)
          }
          .buttonStyle(.chips(selected: frequency == dog.combinationVaccineFrequency))
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
        date: $dog.filariasisDosingDate,
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
        date: $dog.rabiesVaccineDate,
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
//        uiState.route =
      } label: {
        Text("保存")
      }
    }
  }
}

extension DogCreateSecondPage {
  struct UiState {
    var hasBeenVaccinatedWithRabiesVaccine = false
    var hasBeenVaccinatedWithCombinationVaccine = false
    var hasBeenDosedWithFilariasisDrug = false
  }
}

struct DogCreateSecondPage_Previews: PreviewProvider {
  static var previews: some View {
    DogCreateSecondPage(dog: .init())
      .background(Color.Background.primary)
  }
}
