---
name: dependency-injection
description: >-
  Constructor injection, composition-root wiring, and singleton confinement for
  Swift apps. Use when wiring dependencies, view models, services, static shared,
  or when the user mentions DI, injection, or composition root.
---

# Dependency injection

Construct and wire dependencies only at the composition root (the app's DI container or bootstrap type — discover its name from the current repo).

## Rules

- Use initializer (constructor) injection for all collaborators.
- Depend on protocol abstractions, not concrete types, where testability matters.
- No direct singleton access outside the composition root and bootstrap code.
- No global shared state or service locators outside the composition root.
- Views receive fully built view models from the container; they do not construct dependencies.
- The composition root uses explicit factory methods with construction code, not a string-key or dictionary registry.
- Stored properties and intermediate factory methods on the container should be `private`. Only `init()` and the single root-object factory exposed to the app entry point are internal or wider.

## Singletons

Singletons may exist when they represent a naturally shared application-wide resource. A type may expose `static let shared`, but **only the composition root and bootstrap code** may reference it.

Application code must not directly access singleton instances (for example, `Logger.shared`). Inject abstractions through constructors instead. Dependent types should not know whether the implementation is a singleton, a new instance, or a test double.

A singleton is an implementation detail of dependency assembly, not a dependency-management mechanism.

## Examples

```swift
// BAD — resolving inside a view model
final class DashboardViewModel {
    private let store = DataStore.shared
}

// BAD — constructing services inline in a view
struct DashboardView: View {
    @State private var viewModel = DashboardViewModel(store: DataStore())
}

// GOOD — container owns lifetimes and wiring
final class CompositionRoot {
    private let store = DataStore()

    private func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(store: store)
    }

    func makeRootViewModel() -> RootViewModel {
        RootViewModel(dashboard: makeDashboardViewModel())
    }
}
```

Discover the project's composition-root type and factory naming from the codebase.
