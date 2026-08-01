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
            url: "https://github.com/antyukhin/strata-dist/releases/download/0.11.0/Strata.xcframework.zip",
            checksum: "3cc881293a21c73a876d464fc8f8f5f03fd4440c43a5153deed60bc9705cfaf3" // ← вывод `swift package compute-checksum` / --release
        ),
    ]
)
