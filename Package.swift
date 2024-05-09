// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PlayKitProviders",
    platforms: [.iOS(.v14),
                .tvOS(.v14)],
    products: [.library(name: "PlayKitProviders",
                        targets: ["PlayKitProviders"])],
    dependencies: [
        .package(url: "https://github.com/yahoojapan/SwiftyXMLParser.git", from: "5.6.0"),
        .package(name: "PlayKit",
                 url: "https://github.com/kaltura/playkit-ios.git",
                 .upToNextMinor(from: "3.30.0")),
    ],
    targets: [.target(name: "PlayKitProviders",
                      dependencies: [
                        "SwiftyXMLParser",
                        .product(name: "AnalyticsCommon", package: "PlayKit"),
                      ],
                      path: "Sources/")
    ]
)
