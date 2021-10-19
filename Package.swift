// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ctble",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "ctble",
            targets: ["ctble"]),
    ],
    dependencies: [
        .package(name: "RxSwift", url: "https://github.com/ReactiveX/RxSwift.git", from: "5.1.2")
    ],
    targets: [
        .target(
            name: "ctble",
            dependencies: ["RxSwift"],
            path: "Source")
    ]
)
