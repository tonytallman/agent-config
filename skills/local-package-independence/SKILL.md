---
name: local-package-independence
description: >-
  Enforces independence between local Swift packages with composition-root and
  view-package exceptions. Use when editing Package.swift path dependencies,
  local package graphs, or forbidden cross-package deps.
---

# Local package independence

Local packages must not depend on other local packages, with these exceptions:

1. The **composition-root / DI package** may depend on any local package.
2. **View packages** may depend on the **design-system** package.
3. **View packages** may depend on other **view packages**.

All other cross-package dependencies are prohibited. **Logic packages** must remain fully independent of every other local package.

Discover composition-root, design-system, logic vs view package names and templates from the current repo.

## Decoupling

When a capability must cross package boundaries without adding an allowed `Package.swift` dependency, follow the **local-package-decoupling** skill: abstraction in the consumer, concrete types in the provider, wire at the composition root.
