// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ctble_ios",
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.1.2")
    ]
)
