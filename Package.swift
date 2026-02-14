// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CamiCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "CamiCore", targets: ["CamiCore"])
    ],
    targets: [
        .target(
            name: "CamiCore",
            path: "Sources/CamiCore"
        ),
        .testTarget(
            name: "CamiCoreTests",
            dependencies: ["CamiCore"],
            path: "Tests/CamiCoreTests"
        )
    ]
)
