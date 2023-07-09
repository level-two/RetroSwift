// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "RetroSwift",
    products: [
        .library(
            name: "RetroSwift",
            targets: ["RetroSwift"]),
    ],
    targets: [
        .target(
            name: "RetroSwift",
            path: "RetroSwift"),
        .testTarget(
            name: "RetroSwiftTests",
            dependencies: ["RetroSwift"],
            path: "RetroSwiftTests")
    ]
)
