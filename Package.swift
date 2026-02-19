// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacTranslator",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "MacTranslator",
            path: "Sources/MacTranslator",
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("Carbon"),
            ]
        ),
    ]
)
