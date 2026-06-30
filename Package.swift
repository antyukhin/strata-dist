// swift-tools-version: 6.0
import PackageDescription

// Бинарная дистрибуция Strata. Исходники ядра не входят — только скомпилированный
// XCFramework, опубликованный как ассет GitHub Release. checksum обновляется на каждый
// релиз (выводит ./build-xcframework.sh --release <tag> в репо ядра).
let package = Package(
    name: "Strata",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Strata", targets: ["Strata"]),
    ],
    targets: [
        .binaryTarget(
            name: "Strata",
            url: "https://github.com/antyukhin/strata-dist/releases/download/0.8.7/Strata.xcframework.zip",
            checksum: "62db061a59fa2f113ce54a2eb85d48bd5a63677315444e9c87877ee8f0cce0f7" // ← вывод `swift package compute-checksum` / --release
        ),
    ]
)
