// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SamplePackage",
  defaultLocalization: "ja",
  platforms: [.iOS(.v16)],
  products: [
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "CertifiateFeature", targets: ["CertifiateFeature"]),
    .library(name: "ScheduleFeature", targets: ["ScheduleFeature"]),
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
        "CertifiateFeature",
        "Core",
        "DogFeature",
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
        "SharedComponents",
      ]
    ),
    .target(
      name: "CertifiateFeature",
      dependencies: [
        "FirebaseClient",
        "SharedComponents",
      ]
    ),
    .target(name: "Core"),
    .testTarget(name: "CoreTests", dependencies: ["Core"]),
    .target(
      name: "DataStore",
      dependencies: [
        "FirebaseClient",
      ]
    ),
    .target(
      name: "DogFeature",
      dependencies: [
        "FirebaseClient",
        "SharedComponents",
      ]
    ),
    .target(
      name: "FirebaseClient",
      dependencies: [
        "Core",
        "SharedModels",
        .product(name: "FirebaseAuth", package: "Firebase"),
        .product(name: "FirebaseStorage", package: "Firebase"),
      ]
    ),
    .target(
      name: "HomeFeature",
      dependencies: [
        "Core",
        "FirebaseClient",
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
      ]
    ),
    .target(
      name: "SharedComponents",
      dependencies: [
        "FirebaseClient",
        "SharedModels",
        "Styleguide",
      ],
      resources: [.process("Resources/"),]
    ),
    .target(
      name: "SharedModels",
      dependencies: [
        "Core",
        .product(name: "FirebaseFirestore", package: "Firebase"),
        .product(name: "FirebaseFirestoreSwift", package: "Firebase"),
      ]
    ),
    .target(
      name: "Styleguide",
      resources: [.process("Resources/"),]
    ),
    .target(name: "UserNotificationClient"),
  ]
)
