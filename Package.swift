// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SamplePackage",
  defaultLocalization: "ja",
  platforms: [.iOS(.v15)],
  products: [
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "Styleguide", targets: ["Styleguide"]),
    .library(name: "SharedComponents", targets: ["SharedComponents"]),
  ],
  dependencies: [
    .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", from: "9.0.0"),
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        "Core",
        "OnboardingFeature",
        "SharedComponents",
        "UserNotificationClient",
//        .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
        .product(name: "FirebaseAuth", package: "Firebase"),
//        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
//        .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
      ]
    ),
    .testTarget(name: "AppFeatureTests", dependencies: ["AppFeature"]),
    .target(name: "Core"),
    .target(
      name: "DataSource",
      dependencies: [
        "FirebaseClient",
        "SharedModels",
      ]
    ),
    .target(
      name: "DataStore",
      dependencies: [
        "DataSource",
        "FirebaseClient",
        "SharedModels",
      ]
    ),
    .target(
      name: "FirebaseClient",
      dependencies: [
        "SharedModels",
        .product(name: "FirebaseAuth", package: "Firebase"),
      ]
    ),
    .target(
      name: "OnboardingFeature",
      dependencies: [
        "Core",
        "DataStore",
        "FirebaseClient",
        "SharedComponents",
        "Styleguide",
        "SwiftUIHelper",
      ]
    ),
    .target(
      name: "SharedComponents",
      dependencies: ["Styleguide"],
      resources: [.process("Resources/"),]
    ),
    .target(name: "SharedModels"),
    .target(
      name: "Styleguide",
      resources: [.process("Resources/"),]
    ),
    .target(name: "SwiftUIHelper"),
    .target(name: "UserNotificationClient"),
  ]
)
