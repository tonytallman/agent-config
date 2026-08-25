---
name: local-package-decoupling
description: >-
  Decouples local Swift packages via consumer-side abstractions and composition-root
  wiring. Use when adding cross-package behavior without a Package.swift dependency,
  removing forbidden local deps, protocols, adapters, or composition root.
---

# Local package decoupling

Use when two local packages must interact but **local-package-independence** forbids (or you want to avoid) a direct SPM dependency.

## Checklist

1. **Consumer** — Pick the narrowest consuming target/module (not the whole package if only one target needs the capability).
2. **Abstraction** — Define a minimal protocol or type-erased surface **in that module**; shape it for call sites there, not the provider's internals.
3. **Provider** — Keep concrete types in the provider module that already owns them.
4. **Composition root** — Implement the abstraction in the DI package (preferred) or the app target; register instances/factories/environment so only the abstraction crosses the boundary.
5. **Imports** — The consuming target must not `import` the provider module without a package dependency; adapters may import both.
6. **Do not** add forbidden `path:` dependencies to work around visibility.
7. **Tests** — Mock the abstraction in consumer tests; exercise real wiring in composition-root or app tests if present.

## Swift notes

- Prefer small protocols or a struct of closures / `AnyPublisher` over exposing whole services.
- Do not widen `public` on provider types to hack around missing dependencies; fix the boundary instead.

Discover the composition-root package name from the current repo.
