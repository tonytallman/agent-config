---
name: protocol-decorator
description: >-
  Implements Swift protocol decoration with a wrapping class, full forwarding,
  and a fluent withCapability() extension. Use when adding behavior that applies
  to any protocol instance, or when the user mentions decorator, decorate, wrap
  a protocol, or fluent withLogging-style wrappers.
---

# Protocol decorator

Use when new behavior works equally well on **any instance of a protocol**. Wrap an instance; do not add the behavior to every conformer and do not subclass to intercept.

Follow **swift-visibility** for access control. The protocol is `public` (it preexists the decorator). The decorator class and its `init` are `internal` (app target) or `package` (SPM target) — never `public`. The fluent extension is `public`. Only the protocol and the extension are visible to the composition root; the decorator type is not.

## Pattern

1. **`final class`** named `{Protocol}With{Capability}` (e.g. `AbstractionWithLogging`). Visibility `package` or `internal` — never `public`.
2. **Composition**: `private let wrapped: any Abstraction` and `init(wrapping wrapped: any Abstraction)` at the same visibility as the class.
3. **Forward** every protocol requirement to `wrapped`; decorate only the members that need extra behavior.
4. **Fluent API** — `public extension` on the protocol, returning the **protocol** (not `Self` or the decorator type):

```swift
public extension Abstraction {
    func withLogging() -> any Abstraction {
        AbstractionWithLogging(wrapping: self)
    }
}
```

5. **Construction**: `SomeConformingType().withLogging()`; chain fluent calls. Prefer wiring at the composition root (**dependency-injection**).
6. **Isolation**: if the protocol is `@MainActor` (or otherwise isolated), the decorator matches that isolation.

## Example

```swift
public protocol DataStore {
    var name: String { get }
    func save(_ value: String) throws
}

final class DataStoreWithLogging: DataStore {
    private let wrapped: any DataStore

    init(wrapping wrapped: any DataStore) {
        self.wrapped = wrapped
    }

    var name: String { wrapped.name }

    func save(_ value: String) throws {
        print("Calling save(\(value)) on \(name)...")
        try wrapped.save(value)
        print("save(\(value)) completed")
    }
}

public extension DataStore {
    func withLogging() -> any DataStore {
        DataStoreWithLogging(wrapping: self)
    }
}

// Construction — single decorator or chained
let store = InMemoryDataStore().withLogging()
```

## Counter-examples

```swift
// BAD — behavior duplicated on every conformer
class FileStore: DataStore {
    func save(_ value: String) throws {
        print("Calling save...") // repeated in InMemoryDataStore, CloudDataStore, …
        // ...
    }
}

// BAD — fluent API exposes the decorator type
public extension DataStore {
    func withLogging() -> DataStoreWithLogging { ... }
}

// BAD — decorator is public
public final class DataStoreWithLogging: DataStore { ... }

// BAD — subclassing to intercept instead of decorating
final class LoggingFileStore: FileStore {
    override func save(_ value: String) throws { ... }
}
```
