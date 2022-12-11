// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PlayKitProviders",
    platforms: [.iOS(.v11),
                .tvOS(.v11)],
    products: [.library(name: "PlayKitProviders",
                        targets: ["PlayKitProviders"])],
    dependencies: [
        .package(url: "https://github.com/yahoojapan/SwiftyXMLParser.git", from: "5.0.0"),
        .package(name: "PlayKitUtils",
                 url: "https://github.com/kaltura/playkit-ios-utils.git",
                 .branch("FEC-12640")),
        .package(name: "KalturaNetKit",
                 url: "https://github.com/kaltura/netkit-ios.git",
                 .branch("FEC-12640")),
        .package(name: "PlayKit",
                 url: "https://github.com/kaltura/playkit-ios.git",
                 .branch("FEC-12640")),
    ],
    targets: [.target(name: "PlayKitProviders",
                      dependencies: [
                        "SwiftyXMLParser",
                        .product(name: "AnalyticsCommon", package: "PlayKit"),
                        .product(name: "KalturaNetKit", package: "KalturaNetKit"),
                        .product(name: "PlayKitUtils", package: "PlayKitUtils"),
                      ],
                      path: "Sources/")
    ]
)
