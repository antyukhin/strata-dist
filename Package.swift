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
            url: "https://github.com/antyukhin/strata-dist/releases/download/0.13.0/Strata.xcframework.zip",
            checksum: "7119c8661e861c26fba3ba0eaa0d87e20b321c3ae252c639ebc1cebe1088bd2a" // ← вывод `swift package compute-checksum` / --release
        ),
    ]
)
