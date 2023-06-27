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
            path: "Sources",
            dependencies: []),
        .testTarget(
            name: "RetroSwiftTests",
            path: "Tests",
            dependencies: ["RetroSwift"]),
    ]
)
