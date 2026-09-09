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

Follow **swift-visibility**. Preserve the protocol's existing visibility. The decorator class and its `init` are usually `internal`, since only the adjacent fluent extension constructs it. Callers never name the concrete decorator.

## Pattern

1. Default to a **`final class`** named `{Protocol}With{Capability}` (e.g. `AbstractionWithLogging`) — stable identity, shared state, consistent isolation. Use an `actor` instead only when the wrapper must protect its own mutable state across concurrent callers and the protocol's requirements are async (an actor cannot satisfy synchronous requirements).
2. **Composition**: `private let wrapped: any Abstraction` and `init(wrapping wrapped: any Abstraction)`.
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
6. **Isolation**: if the protocol is `@MainActor` (or otherwise isolated), the decorator matches that isolation. If the protocol refines `Sendable` or crosses isolation boundaries, the decorator must be `Sendable` too; a stateful decorator on a `Sendable` protocol is the actor case above — never `@unchecked Sendable` with a lock.
7. **Testing**: decorators get forwarding and decorated-behavior tests per **swift-testing**.
8. If this skill's requirements conflict with the protocol's isolation or `Sendable` requirements, say so in your response instead of working around it.

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

// BAD — @unchecked Sendable wrapper with a lock; use an actor
final class DataStoreWithSharing: DataStore, @unchecked Sendable {
    private let lock = NSLock()
    // ...
}

// BAD — subclassing to intercept instead of decorating
final class LoggingFileStore: FileStore {
    override func save(_ value: String) throws { ... }
}
```
