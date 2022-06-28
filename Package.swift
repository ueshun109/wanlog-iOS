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
        "HomeFeature",
        "OnboardingFeature",
        "SharedComponents",
        "SharedModels",
        "ScheduleFeature",
        "UserNotificationClient",
//        .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
        .product(name: "FirebaseAuth", package: "Firebase"),
//        .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
//        .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
      ]
    ),
    .testTarget(name: "AppFeatureTests", dependencies: ["AppFeature"]),
    .target(
      name: "ScheduleFeature",
      dependencies: [
        "DataStore",
      ]
    ),
    .target(name: "Core"),
    .target(
      name: "DataStore",
      dependencies: [
        "FirebaseClient",
      ]
    ),
    .target(
      name: "FirebaseClient",
      dependencies: [
        "Core",
        "SharedModels",
        .product(name: "FirebaseAuth", package: "Firebase"),
      ]
    ),
    .target(
      name: "HomeFeature",
      dependencies: [
        "Core",
        "SharedModels",
        "Styleguide",
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
      dependencies: [
        "SharedModels",
        "Styleguide",
      ],
      resources: [.process("Resources/"),]
    ),
    .target(
      name: "SharedModels",
      dependencies: [
        .product(name: "FirebaseFirestore", package: "Firebase"),
        .product(name: "FirebaseFirestoreSwift", package: "Firebase"),
      ]
    ),
    .target(
      name: "Styleguide",
      resources: [.process("Resources/"),]
    ),
    .target(name: "SwiftUIHelper"),
    .target(name: "UserNotificationClient"),
  ]
)
