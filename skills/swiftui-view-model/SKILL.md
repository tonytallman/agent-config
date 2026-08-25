---
name: swiftui-view-model
description: >-
  Default SwiftUI view-model pattern: same-file protocol, generic View,
  Runtime/Preview implementations, presentation-only views. Use when adding
  SwiftUI screens, View, view model, #Preview, @Observable, or Observation.
---

# SwiftUI view model pattern

Default pattern for every SwiftUI app. SwiftUI-specific; not generalized to UIKit.

## Views (presentation only)

SwiftUI `View` types are responsible for layout and presentation only. No business logic, state mutations, or direct access to services or engines.

- A `View` has exactly one primary dependency: a **view model** (screens and composed UI) or a **model value** (simple reusable controls).
- Logic that determines what to show, what action to take, or how to transform data belongs in a view model.
- Views do not construct their own dependencies; all dependencies are passed in from outside.
- Multi-parameter view initialisers signal wiring leaking into the view layer.

## View model pattern

Screen-level `View` types that use a view model define the view model's shape with a top-level protocol in the same Swift file as the view.

- Define `@MainActor protocol FooViewModel: AnyObject, Observable` in `Views/FooView.swift`, outside and immediately before `FooView`.
- Declare the view as `struct FooView<ViewModel: FooViewModel>: View`.
- Runtime implementation: `@Observable @MainActor final class RuntimeFooViewModel: FooViewModel` in `ViewModels/FooViewModel.swift`.
- Preview implementation: `@Observable @MainActor final class PreviewFooViewModel: FooViewModel`.
- Preview class and all `#Preview` blocks wrapped in `#if DEBUG`.
- Preview view models colocated in `ViewModels/PreviewViewModels.swift`.
- Child view models: parent protocol uses `associatedtype` constrained to the child protocol; implementation returns `some ChildViewModelProtocol` from a private backing property.
- Import `Observation` alongside `SwiftUI` where view-model protocols are declared.

## Example

```swift
// Views/SettingsView.swift
import Observation
import SwiftUI

@MainActor
protocol SettingsViewModel: AnyObject, Observable {
    var title: String { get }
    var isSaving: Bool { get }
    func save()
}

struct SettingsView<ViewModel: SettingsViewModel>: View {
    @Bindable var viewModel: ViewModel
    var body: some View { /* ... */ }
}

#if DEBUG
#Preview {
    SettingsView(viewModel: PreviewSettingsViewModel())
}
#endif
```

## Counter-examples

```swift
// BAD — view tied to concrete runtime implementation
struct SettingsView: View {
    @Bindable var viewModel: RuntimeSettingsViewModel
}

// BAD — protocol separated from the view it shapes
// ViewModels/SettingsViewModel.swift — protocol only, wrong file

// BAD — preview compiled in non-DEBUG builds
final class PreviewSettingsViewModel: SettingsViewModel { ... }
```
