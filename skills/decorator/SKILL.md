---
name: decorator
description: >-
  Implements Swift protocol decoration with a wrapping class, full forwarding,
  and a fluent withCapability() extension. Use when adding behavior that applies
  to any protocol instance, or when the user mentions decorator, decorate, wrap
  a protocol, or fluent withLogging-style wrappers.
---

# Swift protocol decorator

Use when new behavior works equally well on **any instance of a protocol**. Wrap an instance; do not add the behavior to every conformer and do not subclass to intercept. If the behavior is specific to one concrete type, put it on that type (or extract a protocol first, then decorate).

**Decorator vs adaptor:** a decorator adds behavior to any protocol instance; an **adaptor** converts one specific type to a different interface. Chain them: `source.asSpeedMetric().shared()`.

Follow **swift-visibility**. Preserve the protocol’s existing visibility. Because only the adjacent fluent extension constructs it, the decorator class and its `init` are usually `internal` — even in an SPM target. Use `package` only when another target in the same package constructs it directly. Never `public`. The fluent extension is only as visible as its callers require. Callers need not name the concrete decorator.

## Pattern

1. **`final class`** named `{Protocol}With{Capability}` (e.g. `AbstractionWithLogging`). Visibility `internal` or `package` — never `public`.
2. **Composition**: `private let wrapped: any Abstraction` and `init(wrapping wrapped: any Abstraction)` at the same visibility as the class.
3. **Forward** every protocol requirement to `wrapped`; decorate only the members that need extra behavior. A wrapper inherits protocol-extension defaults, so an override on the wrapped type is lost unless that requirement is forwarded too.
4. **Fluent API** — extension on the protocol, returning the **protocol** (not `Self` or the decorator type):

```swift
extension Abstraction {
    func withLogging(logger: any Logger) -> any Abstraction {
        AbstractionWithLogging(wrapping: self, logger: logger)
    }
}
```

5. **Construction**: chain fluent calls at the composition root (**dependency-injection**). The last call is the outermost wrapper.
6. **Isolation**: if the protocol is `@MainActor` (or otherwise isolated), the decorator matches that isolation.

## Example

```swift
protocol DataStore {
    var name: String { get }
    func save(_ value: String) throws
}

final class DataStoreWithLogging: DataStore {
    private let wrapped: any DataStore
    private let logger: any Logger

    init(
        wrapping wrapped: any DataStore,
        logger: any Logger,
    ) {
        self.wrapped = wrapped
        self.logger = logger
    }

    var name: String { wrapped.name }

    func save(_ value: String) throws {
        logger.log("Calling save(\(value)) on \(name)...")
        try wrapped.save(value)
        logger.log("save(\(value)) completed")
    }
}

extension DataStore {
    func withLogging(logger: any Logger) -> any DataStore {
        DataStoreWithLogging(wrapping: self, logger: logger)
    }
}

// Last fluent call is outermost — each retry attempt is logged
let store = InMemoryDataStore()
    .withLogging(logger: logger)
    .withRetry(attempts: 3)
```

## Protocols with associated types

Use a generic decorator. Returning `any Metric<Value>` requires a primary associated type (`protocol Metric<Value>`); add one if missing rather than returning the decorator type.

```swift
final class MetricWithSharing<Value>: Metric {
    private let wrapped: any Metric<Value>
    init(wrapping wrapped: any Metric<Value>) { self.wrapped = wrapped }
    // forward Metric requirements
}
extension Metric {
    func shared() -> any Metric<Value> { MetricWithSharing(wrapping: self) }
}
```

## Counter-examples

```swift
// BAD — behavior duplicated on every conformer
class FileStore: DataStore {
    func save(_ value: String) throws {
        logger.log("Calling save...") // repeated in InMemoryDataStore, CloudDataStore, …
        // ...
    }
}

// BAD — fluent API exposes the decorator type
extension DataStore {
    func withLogging(logger: any Logger) -> DataStoreWithLogging { ... }
}

// BAD — decorator is public
public final class DataStoreWithLogging: DataStore { ... }

// BAD — subclassing to intercept instead of decorating
final class LoggingFileStore: FileStore {
    override func save(_ value: String) throws { ... }
}
```
