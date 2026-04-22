// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tokens",
    products: [
        .library(
            name: "Tokens",
            targets: ["Tokens"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/Position.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Tokens",
            dependencies: [
                .product(name: "Position", package: "Position"),
            ],
        ),
        .testTarget(
            name: "TokensTests",
            dependencies: ["Tokens"]
        ),
    ]
)
