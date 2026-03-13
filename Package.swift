// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sliders",
    platforms: [.iOS(.v26), .macOS(.v26), .watchOS(.v26)],
    products: [
        .library(name: "Sliders", targets: ["Sliders"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Sliders", dependencies: []),
    ]
)
