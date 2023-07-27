// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "RetroSwift",
    platforms: [
        .macOS("10.15"),
        .iOS("13.0"),
        .tvOS("13.0"),
        .watchOS("6.0")
    ],
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
