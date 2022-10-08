import Core
import FirebaseClient
import SharedComponents
import SharedModels
import Styleguide
import SwiftUI

public struct CertificateListPage<Router: Routing>: View where Router._Route == CertificateRoute {
  private struct UiState {
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
        List {
          ForEach(data) { certificate in
            CertificateItem(certificate: certificate)
          }
        }
      }
    } onFailure: { error in

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
      isActive: .constant(false),
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

    var body: some View {
      HStack(alignment: .top, spacing: Padding.xSmall) {
        Rectangle()
          .fill(Color.gray)
          .frame(width: 40, height: 40)
          .clipShape(RoundedRectangle(cornerRadius: 8))

        VStack(alignment: .leading) {
          Text(certificate.title)
            .font(.title3)
            .foregroundColor(Color.Label.primary)

          Text(certificate.description ?? "")
            .font(.caption)
            .foregroundColor(Color.Label.secondary)
        }
        .lineLimit(1)
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

  struct CertificateDetailPreviews: PreviewProvider {
    static var previews: some View {
      CertificateDetail()
    }
  }

  struct CertificateItemPreviews: PreviewProvider {
    static var previews: some View {
      CertificateItem(certificate: .init(dogId: "", title: "タイトル", imageRef: [], date: .init(date: .now)))
    }
  }
}
