// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Lab",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Lab", targets: ["Lab"])
    ],
    targets: [
        .target(name: "Lab", path: "Sources")
    ]
)
