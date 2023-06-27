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
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "RetroSwiftTests",
            dependencies: ["RetroSwift"],
            path: "Tests")
    ]
)
