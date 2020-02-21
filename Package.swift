// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "DictionaryCoding",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS(.v10)
    ],
    products: [
        .library(
            name: "DictionaryCoding",
            targets: ["DictionaryCoding"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "DictionaryCoding",
            dependencies: []),
        .testTarget(
            name: "DictionaryCodingTests",
            dependencies: ["DictionaryCoding"]),
    ]
)
