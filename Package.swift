// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toggl2Redmine",
    platforms: [.macOS(.v10_12)],
    products: [
        .executable(name: "t2r", targets: ["t2r"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.2")),
    ],
    targets: [
        .target(
            name: "t2r",
            dependencies: ["Toggl2RedmineCore", "ArgumentParser"]
        ),
        .target(
            name: "Toggl2RedmineCore",
            dependencies: []
        )
    ]
)
