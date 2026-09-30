// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Lab",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LabCore", targets: ["LabCore"]),
        .library(name: "LabUI", targets: ["LabUI"]),
    ],
    targets: [
        // Foundation-only domain logic; no SwiftUI so it also builds on Linux.
        .target(name: "LabCore", path: "Sources/LabCore"),
        .target(name: "LabUI", dependencies: ["LabCore"], path: "Sources/LabUI"),
        .testTarget(name: "LabCoreTests", dependencies: ["LabCore"], path: "Tests/LabCoreTests"),
    ]
)
