// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toggl2Redmine",
    platforms: [.macOS(.v10_12)],
    products: [
        .executable(name: "t2r", targets: ["Toggl2Redmine"])
    ],
    targets: [
        .target(
            name: "Toggl2Redmine",
            dependencies: []),
        .testTarget(
            name: "Toggl2RedmineTests",
            dependencies: ["Toggl2Redmine"]),
    ]
)
