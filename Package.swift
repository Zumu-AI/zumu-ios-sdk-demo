// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "DriverAppTranslatorDemo",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "DriverAppTranslatorDemo",
            targets: ["DriverAppTranslatorDemo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Zumu-AI/zumu-ios-sdk", branch: "main")
    ],
    targets: [
        .target(
            name: "DriverAppTranslatorDemo",
            dependencies: [
                .product(name: "ZumuTranslator", package: "zumu-ios-sdk")
            ],
            path: "Sources/DriverApp"),
    ]
)
