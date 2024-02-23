// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HackerNewsAPI",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v4),
        .visionOS(.v1),
        .tvOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HackerNewsAPI",
            targets: ["HackerNewsAPI"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "10.21.0")
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HackerNewsAPI",
            dependencies: [
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "HackerNewsAPITests",
            dependencies: [
                "HackerNewsAPI",
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
            ]
        ),
    ]
)
