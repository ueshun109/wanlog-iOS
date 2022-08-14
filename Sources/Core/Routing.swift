import SwiftUI

/// 遷移先を列挙する振る舞いをもたせる`protocol`
public protocol Route {}

/// 遷移先のインスタンスを生成する振る舞いをもたせる`protocol`
@MainActor
public protocol Routing {
  associatedtype _Route: Route
  associatedtype View: SwiftUI.View

  /// Routeに準拠したenumから次の遷移先の`View`のインスタンスを返す
  /// - Parameter with : 遷移先が列挙されたenumの値
  /// - Returns: 遷移先の`View`インスタンス
  @ViewBuilder func view(for route: _Route) -> Self.View
}
