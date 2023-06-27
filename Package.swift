// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "RetroSwift",
    products: [
        .library(
            name: "RetroSwift",
            targets: ["RetroSwift"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RetroSwift",
            dependencies: []),
        .testTarget(
            name: "RetroSwiftTests",
            dependencies: ["RetroSwift"]),
    ]
)
