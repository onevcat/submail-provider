// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Submail",
    products: [
        .library(name: "Submail", targets: ["Submail"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        ],
    targets: [
        .target(name: "Submail", dependencies: ["Vapor"]),
        .testTarget(name: "SubmailTests", dependencies: ["Vapor", "Submail"])
    ]
)
