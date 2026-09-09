---
name: adaptor
description: >-
  Implements Swift type adaptation with asAdaptedType() factories and a
  three-option condition list (existing type, conformance extension, adaptor
  class). Use when converting one concrete type to another interface at the
  composition root, or when the user mentions adaptor, adapter, asMetric,
  asBluetoothSettings, AnyAppStorage, type eraser,
  type-erasing wrapper, or bridging types across package boundaries.
---

# Adaptor

Use when a **specific source type** must be used as a **different interface** (protocol or existing concrete type). Adapt at the composition root; do not widen provider packages or add forbidden local dependencies. If the consumer may legally import the provider (**local-package-independence**), use the type directly instead of adapting.

**Adaptor vs decorator:** an adaptor **converts** one type to another. A **decorator** adds behavior that works on **any** instance of a protocol. Do not mix them — chain at the call site: `source.asSpeedMetric().shared()`.

Follow **swift-visibility** and **local-package-decoupling**. Place adaptors in the module that can `import` both source and target (usually the composition root / DI package), under `Adaptors/` when the project uses that layout. One adaptor per file under `Adaptors/<Provider>/`, named `{SourceType}+{AdaptedType}.swift` (e.g. `Adaptors/Location/CoreLocationSpeedSource+SpeedMetric.swift`). For a type eraser, the filename uses the eraser type (which carries the conformance); the fluent factory still extends the source protocol.

## Implementation options

Choose by situation:

- An existing target-conforming implementation can be initialized from the source → factory builds or wraps it.
- The mapping is canonical and the source is a **concrete type** that can conform without a forbidden package dependency → add the conformance (preferred over a new adaptor type).
- The source is a **protocol existential** (`any SourceProtocol`) → option 2 is impossible; use a dedicated adaptor or type eraser (2b).
- Otherwise → add a new adaptor type.

### 1. Factory returns an existing type

When an existing target-conforming implementation can be initialized from the source, the factory constructs or wraps it.

```swift
extension CoreLocationSpeedSource {
    func asSpeedMetric() -> any Metric<Measurement<UnitSpeed>> {
        RuntimeMetric(
            values: speed,
            isAvailable: isAvailable,
            source: .phone,
        )
    }
}
```

### 2. Protocol-conformance extension

When the mapping is canonical and the source can conform without a forbidden package dependency, add the conformance. Prefer this over a new adaptor type. Omit the factory when call sites already see the conformance; when an explicit hand-off helps, return `self`. A bare conformance extension only works when the source's member signatures already satisfy the target protocol; any renaming or transformation forces option 3.

You cannot write `extension SomeProtocol: OtherProtocol` — Swift does not allow conforming a protocol to another protocol. Choose by whether the source is already a concrete type or a protocol existential.

### 2a. Concrete source

When the static type is already concrete, conform that type directly. Factory may return `self` or `any TargetProtocol`. In Swift 6, use `@retroactive` when conforming a type you do not own to a protocol you do not own.

```swift
extension UserDefaultsAppStorage: SettingsStorage { }

extension UserDefaultsAppStorage {
    func asSettingsStorage() -> any SettingsStorage {
        self
    }
}
```

### 2b. Protocol source

When the source is a **protocol** (e.g. `AppStorage`) and call sites hold `any AppStorage` after decorators such as `withNamespacedKeys`, you cannot extend the protocol. Choose one of:

- **Dedicated adaptor** (often preferable): wrap `any SourceProtocol` in a `{Source}To{Target}` class (option 3). Use when mapping is non-trivial or you need a single consumer.
- **Type eraser**: add a concrete `Any{Protocol}` class when preserving the source abstraction across multiple consumer conformances is specifically useful.

**Type eraser** (a boxing wrapper for hanging conformances on an existential — not an associated-type eraser like `AnyPublisher`). The eraser class **only** conforms to the **source** protocol. It does not accumulate consumer-protocol conformances. Each consumer protocol gets its own adaptor file with `extension Any{Source}: {Target}` in the **same file** as the fluent factory. Because the eraser conforms to the source protocol, the factory on `extension SourceProtocol` is also visible on the eraser — call it only on un-erased sources.

```swift
// AppStorage/AnyAppStorage.swift — source protocol only
package final class AnyAppStorage: AppStorage {
    private let appStorage: any AppStorage

    package init(_ appStorage: any AppStorage) {
        self.appStorage = appStorage
    }

    package func get(forKey key: String) -> Any? {
        appStorage.get(forKey: key)
    }

    package func set(value: Any?, forKey key: String) {
        appStorage.set(value: value, forKey: key)
    }
}

// Adaptors/Settings/AnyAppStorage+SettingsStorage.swift
extension AnyAppStorage: SettingsStorage { }

extension AppStorage {
    func asSettingsStorage() -> any SettingsStorage {
        AnyAppStorage(self)
    }
}
```

Add a second consumer as a **new** adaptor file — not by editing `AnyAppStorage.swift` (e.g. `Adaptors/Cache/AnyAppStorage+CacheStorage.swift` — same shape, new file).

The eraser is **not** the adaptor; the adaptor is the `extension AnyAppStorage: SettingsStorage`. Factory returns the **adapted interface** (`any SettingsStorage`), not the eraser concrete type.

### 3. New adaptor type

When mapping is non-trivial, add `{Source}To{Target}` (e.g. `AppSettingsToBluetoothSettings`). Default to a `final class`. Use an `actor` instead only when the wrapper must protect its own mutable state across concurrent callers and the target protocol's requirements are async (an actor cannot satisfy synchronous requirements). Prefer **composition** (`private let source: SourceType`); use inheritance only when you must subclass a type you do not own.

```swift
final class AppSettingsToBluetoothSettings: BluetoothSettings {
    private let appSettings: AppSettings

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
    }

    // map each BluetoothSettings requirement from appSettings
}

extension AppSettings {
    func asBluetoothSettings() -> any BluetoothSettings {
        AppSettingsToBluetoothSettings(appSettings: self)
    }
}
```

## Fluent factory API

- Name: `as[AdaptedType]()` on the **source** instance (e.g. `asBluetoothSettings()`, `asSpeedMetric()`).
- Use a **specific** name when one source maps to several targets (`asSpeedMetric()`, `asCadenceMetric()`).
- Prefer instance methods. Use `static` only when there is no instance to extend.
- Factory returns the **adapted type** (protocol or existing concrete type), never a `*To*` adaptor class or type-eraser concrete type. Use `any` for protocol existentials.
- Visibility: follow **swift-visibility**. Factories are usually `internal`, since only the composition root calls them.
- Match `@MainActor` (or other isolation) required by the target interface.

## Construction

Wire at the composition root (**dependency-injection**):

```swift
let speed = coreLocationSpeedSource.asSpeedMetric().shared()
let storage = appStorage
    .withNamespacedKeys("Settings")
    .asSettingsStorage()
let bluetooth = appSettings.asBluetoothSettings()
```

Decorators chain after adaptation: `source.asSpeedMetric().shared()`.

Composition-root adaptors are exempt from unit tests. Decorators get forwarding and behavior tests per **swift-testing**.

## Counter-examples

```swift
// BAD — *Adaptors enum when an instance factory is enough
enum CoreLocationMetricAdaptors {
    static func speed(source: CoreLocationSpeedSource) -> any Metric<...> { ... }
}

// BAD — factory returns the adaptor class
extension AppSettings {
    func asBluetoothSettings() -> AppSettingsToBluetoothSettings { ... }
}

// BAD — factory returns the type eraser instead of the adapted interface
extension AppStorage {
    func asSettingsStorage() -> AnyAppStorage { ... } // return any SettingsStorage
}

// BAD — conforming a protocol to another protocol
extension AppStorage: SettingsStorage { }

// BAD — growing the type eraser with every consumer protocol
package final class AnyAppStorage: AppStorage, SettingsStorage, OtherStorage { ... }

// BAD — adding SettingsStorage on AnyAppStorage in AppStorage/AnyAppStorage.swift
// Put extension AnyAppStorage: SettingsStorage in Adaptors/Settings/AnyAppStorage+SettingsStorage.swift

// BAD — adaptor in a logic package that needs a forbidden local dependency
// Put the adaptor in DependencyContainer instead.

// BAD — baking shared()/logging into the adaptor
extension CoreLocationSpeedSource {
    func asSpeedMetric() -> any Metric<...> {
        RuntimeMetric(...).shared() // use decorator at call site
    }
}

// BAD — using an adaptor to add cross-cutting behavior to any protocol instance
// Use decorator with withLogging() instead.
```
