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
            url: "https://github.com/antyukhin/strata-dist/releases/download/0.14.0/Strata.xcframework.zip",
            checksum: "608af940e6223f3abe42f0fa05a30ebd7d62a41340b66e8d19b2ff99acb8b235" // ← вывод `swift package compute-checksum` / --release
        ),
    ]
)
