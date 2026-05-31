// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SetBrowser",
    platforms: [
        .macOS("26.0")
    ],
    products: [
        .library(name: "BrowserCore", targets: ["BrowserCore"]),
        .executable(name: "SetBrowserApp", targets: ["SetBrowserApp"]),
        .executable(name: "setbrowser", targets: ["setbrowser"])
    ],
    targets: [
        .target(name: "BrowserCore"),
        .target(name: "BrowserCLI", dependencies: ["BrowserCore"]),
        .executableTarget(name: "SetBrowserApp", dependencies: ["BrowserCore"]),
        .executableTarget(name: "setbrowser", dependencies: ["BrowserCLI"]),
        .testTarget(name: "BrowserCoreTests", dependencies: ["BrowserCore"])
    ]
)
