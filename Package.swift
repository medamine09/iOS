// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YukaLikeCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "YukaLikeCore",
            targets: ["YukaLikeCore"]
        )
    ],
    targets: [
        .target(
            name: "YukaLikeCore"
        ),
        .testTarget(
            name: "YukaLikeCoreTests",
            dependencies: ["YukaLikeCore"]
        )
    ]
)
