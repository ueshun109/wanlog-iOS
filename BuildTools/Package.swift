// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BuildTools",
  platforms: [.macOS(.v10_15)],
  dependencies: [
//    .package(url: "https://github.com/peripheryapp/periphery", from: "3.22.0"),
//    .package(url: "https://github.com/mono0926/LicensePlist", .exact("3.14.2")),
    .package(url: "https://github.com/apple/swift-format", .branch("release/5.6"))
  ],
  targets: [.target(name: "BuildTools", path: "")]
)
