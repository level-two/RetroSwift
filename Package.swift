// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "RetroSwift",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "RetroSwift",
            targets: ["RetroSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/lukepistrol/SwiftLintPlugin", from: "0.2.2")
    ],
    targets: [
        .target(
            name: "RetroSwift",
            path: "RetroSwift",
            plugins: [.plugin(name: "SwiftLint", package: "SwiftLintPlugin")]
        ),
        .testTarget(
            name: "RetroSwiftTests",
            // FIXME: Linter to be added
            dependencies: ["RetroSwift"],
            path: "RetroSwiftTests")
    ]
)
