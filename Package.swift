// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BoostKYC",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BoostKYC",
            targets: ["BoostKYC"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "BoostKYC",
            path: "./BoostKYC.xcframework"
        )
    ]
)
