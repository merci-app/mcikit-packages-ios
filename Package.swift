// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mcikit-packages-ios",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "OTPAuth",
            targets: ["OTPAuth"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OTPAuth",
            dependencies: [],
            path: "OTPAuth/Sources"),
        .testTarget(
            name: "OTPAuthTests",
            dependencies: ["OTPAuth"],
            path: "OTPAuth/Tests"),
    ]
)
