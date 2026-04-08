// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "hhhz",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "hhhz",
            path: "Sources",
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"]),
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("QuartzCore"),
            ]
        ),
    ]
)
