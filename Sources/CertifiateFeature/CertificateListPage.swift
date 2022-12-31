import Core
import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct CertificateListPage<Router: Routing>: View where Router._Route == CertificateRoute {
  private struct UiState {
    /// Flag for whether to push transition.
    var push = false
    /// Firestore query.
    var query: FirebaseFirestore.Query?
    /// Flag for whether to modal transition.
    var showModal: Bool = false
  }
  private let query: Query.Certificate?
  private let router: Router
  @State private var uiState: UiState = .init()
  @State private var route: CertificateRoute? {
    didSet {
      switch route {
      case .create:
        uiState.showModal = true
      case .detail:
        uiState.push = true
      case .none:
        break
      }
    }
  }
  
  public init(
    query: Query.Certificate?,
    router: Router
  ) {
    self.query = query
    self.router = router
  }

  public var body: some View {
    WithFIRQuery(
      skeleton: Certificate.skelton,
      query: uiState.query
    ) { data in
      if data.isEmpty {
        Text("証明書があれば登録してみましょう。")
      } else {
        let (dic, keys) = dictionaryAndKeys(from: data)
        ScrollView {
          LazyVStack(alignment: .leading, spacing: Padding.small, pinnedViews: [.sectionHeaders]) {
            ForEach(keys, id: \.self) { date in
              Section {
                ForEach(dic[date]!, id: \.self) { certificate in
                  CertificateItem(certificate: certificate) {
                    route = .detail(certificate: certificate)
                  }
                }
                .padding(.horizontal, Padding.medium)
              } header: {
                HeaderSection(title: date.toString(.yearAndMonthAndDayWithSlash))
              }
            }
          }
        }
      }
    } onFailure: { error in
      Text(error.localizedDescription)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          route = .create
        } label: {
          Image.plusCircle
        }
      }
    }
    .navigate(
      router: router,
      route: route,
      isActive: $uiState.push,
      isPresented: $uiState.showModal,
      onDismiss: nil
    )
    .onAppear {
      if uiState.query == nil {
        uiState.query = query?.query()
      }
    }
  }

  private struct CertificateItem: View {
    @State var image: UIImage?
    let certificate: Certificate
    let storage: Storage = .storage()
    let action: () -> Void

    var body: some View {
      Button(action: action) {
        HStack(alignment: .top, spacing: Padding.xSmall) {
          if let image = image {
            Image(uiImage: image)
              .resizable()
              .frame(width: 40, height: 40)
              .scaledToFit()
              .clipShape(RoundedRectangle(cornerRadius: 8))
          } else {
            Image.photo
              .resizable()
              .frame(width: 40, height: 40)
              .scaledToFit()
              .clipShape(RoundedRectangle(cornerRadius: 8))
          }

          VStack(alignment: .leading) {
            Text(certificate.title)
              .font(.headline)
              .foregroundColor(Color.Label.primary)

            Text(certificate.description ?? "")
              .font(.caption)
              .foregroundColor(Color.Label.secondary)
          }
          .lineLimit(1)
        }
      }
      .task {
        guard image == nil,
              let ref = certificate.imageRefs.first,
              let data = try? await storage.reference(withPath: ref).get()
        else { return }
        image = UIImage(data: data)
      }
    }
  }

  private struct CertificateDetail: View {
    var body: some View {
      VStack(alignment: .leading, spacing: Padding.large) {
        // Paging可能な画像を表示する
        Rectangle()
          .fill(Color.gray)
          .frame(maxWidth: .infinity)
          .scaledToFit()

        VStack(alignment: .leading, spacing: Padding.xSmall) {
          Text("タイトル")
            .font(.title)

          Text("2022年9月14日")
            .font(.caption)
            .foregroundColor(Color.Label.secondary)

          Divider()

          Text("補足説明補足説明補足説明補足説明補足説明補足説明補足説明補足説明補足説明")
            .font(.body)
        }
        .padding(.horizontal, 16)

        Spacer()
      }
      .foregroundColor(Color.Label.primary)
    }
  }

  private struct HeaderSection: View {
    let title: String

    var body: some View {
      HStack {
        Text(title)
          .font(.headline)
          .padding(.leading, Padding.medium)
          .padding(.vertical, Padding.xSmall)
          .foregroundColor(Color.Label.secondary)
        Spacer()
      }
      .frame(maxWidth: .infinity)
      .background(Color.Background.primary)
    }
  }

  struct CertificateDetailPreviews: PreviewProvider {
    static var previews: some View {
      CertificateDetail()
    }
  }

  struct CertificateItemPreviews: PreviewProvider {
    static var previews: some View {
      CertificateItem(
        certificate: .init(
          dogId: "",
          title: "タイトル",
          imageRefs: [],
          date: .init(date: .now),
          ownerId: ""
        )
      ) { }
    }
  }
}
