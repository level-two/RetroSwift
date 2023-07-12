// swift-tools-version: 5.7

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
            // FIXME: Linter to be added
            dependencies: ["RetroSwift"],
            path: "RetroSwiftTests")
    ]
)
