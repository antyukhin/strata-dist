# Strata

AR-ядро для iOS: наложение материалов на реальные поверхности (стены, пол, потолок),
сканирование и обмер комнаты. Лицензируемый B2B SDK.

Этот репозиторий — **бинарная дистрибуция** SDK: подключается через SPM и поставляет
скомпилированный `Strata.xcframework`. Исходники ядра сюда не входят.

## Требования

- iOS 17+
- Xcode 16+
- iPhone 12 Pro+ (LiDAR) — для функций RoomPlan-отделки и LiDAR-обмера комнаты.
  Остальное (детект поверхностей, наложение материалов, ручной обмер) работает без LiDAR.

## Установка (SPM)

Xcode → **File → Add Package Dependencies…** → вставить URL:

```
https://github.com/antyukhin/strata-dist
```

Выбрать правило версии **Up to Next Major** от `0.8.7` и добавить продукт `Strata` в таргет.

Или в `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/antyukhin/strata-dist", from: "0.8.7"),
],
targets: [
    .target(name: "MyApp", dependencies: ["Strata"]),
]
```

## Быстрый старт

```swift
import UIKit
import Strata

// 1. Описать материал из своего каталога (ядро каталог не знает)
struct MyTile: StrataMaterial {
    var id = "tile-white-60"
    var name = "Белая плитка 60×60"
    var textureURL = Bundle.main.url(forResource: "tile_white", withExtension: "jpg")!
    var physicalSize = CGSize(width: 0.6, height: 0.6) // реальный размер в метрах → тайлинг
    var roughness: Float = 0.3
    var metallic: Float = 0.0
}

final class ViewController: UIViewController, StrataDelegate {
    let session = StrataSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        let arView = session.makeView()
        arView.frame = view.bounds
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(arView)
        session.delegate = self
        try? session.start()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tap)
    }

    @objc func handleTap(_ g: UITapGestureRecognizer) {
        guard let surface = session.surface(at: g.location(in: g.view)) else { return }
        Task { try? await session.apply(MyTile(), to: surface.id) }
    }

    func strata(_ s: StrataSession, didDetect surface: DetectedSurface) {}
    func strata(_ s: StrataSession, didFailWith error: StrataError) {}
}
```

## Публичный API

| Тип | Назначение |
|-----|------------|
| `StrataSession` | Основная AR-сессия: детект поверхностей, наложение/смена материала |
| `StrataView` | RealityKit-вью сессии (`makeView()`) |
| `StrataMaterial` | Протокол материала — реализует клиент (id, текстура, `physicalSize`, PBR) |
| `StrataDelegate` | События сессии: обнаружение поверхности, применение, ошибки |
| `StrataDiagnostics` | Диагностика состояния AR-сессии |
| `StrataError` | Ошибки SDK |
| `StrataRoomSession` + `StrataRoomDelegate` | RoomPlan-отделка с окклюзией (LiDAR) |
| `StrataMeasureSession` + `StrataMeasureDelegate` | Обмер комнаты: LiDAR-контур или ручная «рулетка»; высота → 3D-модель комнаты |

Полная документация по API, RoomPlan и обмеру — в основном репозитории ядра.

## Changelog

### 0.8.7
- Нативная визуализация RoomPlan во время скана (живой каркас стен, окна/двери/
  проёмы, боксы объектов, коучинг) — силами `RoomCaptureView`. Включена по
  умолчанию; `showsScanVisualization: Bool = true` в инициализаторах
  `StrataRoomSession` / `StrataMeasureSession` (`false` — headless-скан без оверлея).
  Хендофф обхода (`StrataRoomSession`) на момент релиза device-верифицируется.

### 0.8.6
- Отслеживание качества AR-трекинга в LiDAR-скане: `StrataMeasureSession.trackingState`
  (`ScanTrackingState`), `isReadyToScan` и пуш `measureSession(_:didChangeTracking:)`.
  Для гейта кнопки «Завершить скан» и подсказок по трекингу. Аддитивно.

### 0.8.5
- `StrataError` конформит `LocalizedError` — `error.localizedDescription` отдаёт
  осмысленное английское сообщение по каждому кейсу (раньше — generic
  Foundation-фоллбэк). Аддитивно, API не изменился.

### 0.8.4
- `StrataMeasureSession.isLiDARAvailable` — публичный статический флаг наличия
  LiDAR/RoomPlan. Клиент решает, предлагать ли выбор режима в UI, не форся
  `.lidar` вслепую.

### 0.8.3
- Минимальный таргет снижен **iOS 18 → iOS 17** (функционал сохранён; на iOS 17
  оверлей/контур RoomPlan-отделки рисуются односторонне — косметика).
- `StrataMeasureSession.start(mode:)` — явный выбор режима обмера вместо
  авто-выбора по железу (вкатилось вместе с 0.8.2).

### 0.8.1
- Бинарная XCFramework-дистрибуция через этот репозиторий.
- LiDAR `buildModelFromScan()` — 3D-модель комнаты из скана без ручного шага высоты.
- Обмер комнаты (`StrataMeasureSession`): авто-режим LiDAR/ручной, редактирование контура,
  замер высоты → замкнутая 3D-модель `Room3DModel`.

## Выпуск нового релиза (для мейнтейнера)

Порядок важен: `gh release create` тегает текущий HEAD этого репо, а коммит с новым
`checksum` появляется уже после — поэтому тег в конце переставляется на него.

1. В репозитории **ядра** собрать и опубликовать ассет:
   ```bash
   ./build-xcframework.sh --release X.Y.Z
   ```
   Создаёт GitHub Release `X.Y.Z` в этом репо, заливает `Strata.xcframework.zip`,
   печатает `checksum` и готовый блок `binaryTarget`.
2. В этом репо обновить `url` и `checksum` в `Package.swift` под версию `X.Y.Z`.
3. Закоммитить и переставить тег на коммит с checksum:
   ```bash
   git commit -am "release: Strata X.Y.Z binary (checksum)"
   git push origin main
   git tag -f X.Y.Z HEAD          # тег уже создан шагом 1 — двигаем на этот коммит
   git push -f origin X.Y.Z
   ```
4. Проверить, что ассет на месте: `gh release view X.Y.Z --repo antyukhin/strata-dist`.
