---
name: adaptor
description: >-
  Implements Swift type adaptation with asAdaptedType() factories and a
  three-option condition list (existing type, conformance extension, adaptor
  class). Use when converting one concrete type to another interface at the
  composition root, or when the user mentions adaptor, adapter, asMetric,
  asBluetoothSettings, or bridging types across package boundaries.
---

# Adaptor

Use when a **specific source type** must be used as a **different interface** (protocol or existing concrete type). Adapt at the composition root; do not widen provider packages or add forbidden local dependencies.

**Adaptor vs decorator:** an adaptor **converts** one type to another. A **protocol-decorator** adds behavior that works on **any** instance of a protocol. Do not mix them — chain at the call site: `source.asSpeedMetric().shared()`.

Follow **swift-visibility** and **local-package-decoupling**. Place adaptors in the module that can `import` both source and target (usually the composition root / DI package), under `Adaptors/` when the project uses that layout. One adaptor per file under `Adaptors/<Provider>/`, named `{SourceType}+{AdaptedType}.swift` (e.g. `Adaptors/Location/CoreLocationSpeedSource+SpeedMetric.swift`).

## Implementation options

Choose by situation:

- An existing target-conforming implementation can be initialized from the source → factory builds or wraps it.
- The mapping is canonical and the source can conform without a forbidden package dependency → add the conformance (preferred over a new adaptor type).
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

When the mapping is canonical and the source can conform without a forbidden package dependency, add the conformance. Prefer this over a new adaptor type. Omit the factory when call sites already see the conformance; when an explicit hand-off helps, return `self`.

```swift
extension AppStorage: SettingsStorage { }

// Optional — only when a call site needs an explicit hand-off:
extension AppStorage {
    func asSettingsStorage() -> any SettingsStorage {
        self
    }
}
```

### 3. New adaptor type

When mapping is non-trivial, add `final class {Source}To{Target}` (e.g. `AppSettingsToBluetoothSettings`). Prefer **composition** (`private let source: SourceType`); use inheritance only when you must subclass a type you do not own.

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
- Factory returns the **adapted type** (protocol or existing concrete type), never the adaptor class. Use `any` for protocol existentials.
- Visibility: most restrictive that compiles (**swift-visibility**). Composition-root factories are usually `internal` even in an SPM target; use `package` only when another target in the same package calls the factory — do not default to `public`.
- Match `@MainActor` (or other isolation) required by the target interface.

## Construction

Wire at the composition root (**dependency-injection**):

```swift
let speed = coreLocationSpeedSource.asSpeedMetric().shared()
let storage = appStorage.asSettingsStorage()
let bluetooth = appSettings.asBluetoothSettings()
```

Decorators chain after adaptation: `source.asSpeedMetric().shared()`.

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

// BAD — adaptor type is public
public final class AppSettingsToBluetoothSettings: BluetoothSettings { ... }

// BAD — adaptor in a logic package that needs a forbidden local dependency
// Put the adaptor in DependencyContainer instead.

// BAD — baking shared()/logging into the adaptor
extension CoreLocationSpeedSource {
    func asSpeedMetric() -> any Metric<...> {
        RuntimeMetric(...).shared() // use protocol-decorator at call site
    }
}

// BAD — using an adaptor to add cross-cutting behavior to any protocol instance
// Use protocol-decorator with withLogging() instead.
```
