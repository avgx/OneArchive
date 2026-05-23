// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "OneArchive",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "OneArchive",
            targets: ["OneArchive"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/avgx/RequestResponse", from: "2.0.0"),
        .package(url: "https://github.com/avgx/SafeEnum", from: "1.0.0"),
        .package(url: "https://github.com/avgx/OneWireFormat", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "OneArchive",
            dependencies: [
                .product(name: "RequestResponse", package: "RequestResponse"),
                .product(name: "SafeEnum", package: "SafeEnum"),
                .product(name: "OneWireFormat", package: "OneWireFormat"),
            ]
        ),
        .testTarget(
            name: "OneArchiveTests",
            dependencies: ["OneArchive"],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
