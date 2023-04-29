// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "AdaptiveNavigator",
  platforms: [.iOS(.v14)],
  products: [
    .library(
      name: "AdaptiveNavigator",
      targets: ["AdaptiveNavigator"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "AdaptiveNavigator",
      dependencies: []
    ),
    .testTarget(
      name: "AdaptiveNavigatorTests",
      dependencies: ["AdaptiveNavigator"]
    ),
  ]
)
