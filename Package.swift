// swift-tools-version:5.3

// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Rain",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        //一个用于创建命令行接口的纯Swift库
        .package(name: "CommandLineKit", url: "https://github.com/benoit-pereira-da-silva/CommandLine.git", from: "4.0.0"),
        //高亮输出
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.1.5"),
        //处理文件
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Rain",
            dependencies: ["Rainbow",
                           "CommandLineKit",
                           "PathKit",
                           "RainKit"]),
        .target(
            name: "RainKit",
            dependencies: ["Rainbow",
                            "PathKit",
                            "Yams"]),
        .testTarget(
            name: "RainTests",
            dependencies: ["Rain"]),
    ]
)
