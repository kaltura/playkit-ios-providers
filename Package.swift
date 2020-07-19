// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "PlayKitProviders",
    platforms: [
        .iOS(.v9), .tvOS(.v9)
    ],
    products: [
        .library(
            name: "PlayKitProviders",
            targets: ["PlayKitProviders"]),
    ],
    dependencies: [
        .package(name: "PlayKit", url: "https://github.com/kaltura/playkit-ios.git", .branch("spm")),
    ],
    targets: [
        .target(
            name: "PlayKitProviders",
            dependencies: [
                "PlayKit",
            ],
            path: "Sources"
        )
    ]
)
