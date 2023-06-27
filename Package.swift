// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "RetroSwift",
    platforms: [.iOS(.v13)],
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
            path: "RetroSwift"),
        .testTarget(
            name: "RetroSwiftTests",
            dependencies: ["RetroSwift"],
            path: "RetroSwiftTests")
    ]
)
