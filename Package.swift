// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "NIOHTTPClient",
    products: [
        .library(
            name: "NIOHTTPClient",
            targets: ["NIOHTTPClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.13.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "1.4.0"),
    ],
    targets: [
        .target(
            name: "NIOHTTPClient",
            dependencies: ["NIO", "NIOHTTP1", "NIOOpenSSL"]),
        .testTarget(
            name: "NIOHTTPClientTests",
            dependencies: ["NIOHTTPClient"]),
    ]
)
