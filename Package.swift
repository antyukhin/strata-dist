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
            url: "https://github.com/antyukhin/strata-dist/releases/download/0.16.0/Strata.xcframework.zip",
            checksum: "892a54f961bee2a02290dc82f76dfcd9d7fc82e4e242070650cbdcdc4c8cf7c3" // ← вывод `swift package compute-checksum` / --release
        ),
    ]
)
