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

  /// ディープリンクから次の遷移先を表す`Route`インスタンスを返す
  /// - Returns: 次の遷移先の`Route`
  func route(from deeplink: URL) -> _Route?
}

/// 遷移先のインスタンスを生成する振る舞いをもたせる`protocol`
@MainActor
public protocol Routing2 {
  associatedtype _Route: Route
  associatedtype View: SwiftUI.View

  /// Routeに準拠したenumから次の遷移先の`View`のインスタンスを返す
  /// - Parameter with : 遷移先が列挙されたenumの値
  /// - Returns: 遷移先の`View`インスタンス
  @ViewBuilder static func view(for route: _Route) -> Self.View

  /// ディープリンクから次の遷移先を表す`Route`インスタンスを返す
  /// - Returns: 次の遷移先の`Route`
  static func route(from deeplink: URL) -> _Route?
}
