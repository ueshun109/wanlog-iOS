import SwiftUI

public extension View {
  func navigate<Router: Routing>(
    router: Router,
    route: Router._Route?,
    isActive: Binding<Bool>,
    isPresented: Binding<Bool>,
    onDismiss: (() -> Void)?
  ) -> some View {
    self.modifier(
      NavigationModifier(
        router: router,
        route: route,
        isActive: isActive,
        isPresented: isPresented,
        onDismiss: onDismiss
      )
    )
  }
}

/// Push遷移、Modal遷移を行う`ViewModifier`
public struct NavigationModifier<Router: Routing>: ViewModifier {
  private let router: Router
  private let route: Router._Route?
  private let onDismiss: (() -> Void)?
  @Binding private var isActive: Bool
  @Binding private var isPresented: Bool

  public init(
    router: Router,
    route: Router._Route?,
    isActive: Binding<Bool> = .constant(false),
    isPresented: Binding<Bool> = .constant(false),
    onDismiss: (() -> Void)? = nil
  ) {
    self.router = router
    self.route = route
    self.onDismiss = onDismiss
    self._isActive = isActive
    self._isPresented = isPresented
  }

  public func body(content: Content) -> some View {
    content
      .background(
        NavigationLink(
          isActive: $isActive,
          destination: {
            if let route = route {
              router.view(for: route)
            } else {
              EmptyView()
            }
          },
          label: { EmptyView() }
        )
      )
      .sheet(
        isPresented: $isPresented,
        onDismiss: onDismiss
      ) {
        if let route = route {
          router.view(for: route)
        } else {
          EmptyView()
        }
      }
  }
}
