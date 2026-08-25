---
name: swift-visibility
description: >-
  Applies most-restrictive Swift access control; package only in SPM targets;
  forbids @testable import. Use when adding or changing Swift types, members,
  test targets, or when the user mentions visibility, access control, package,
  public, or test-only DI.
---

# Swift visibility

## Default ladder

Use the most restrictive modifier that still compiles:

`private` → `fileprivate` → `internal` (omit keyword) → `package` → `public` / `open`

Do not mark something `public` because tests or another file in the package need it.

## package is package-only

Use `package` only in Swift Package Manager library (and test) targets — e.g. `Sources/` and `Tests/` of a package. Never use `package` in an Xcode app/project target such as `SampleApp/`. There, the ladder stops at `internal` (or `public`/`open` only if another module must import it).

## Same-package tests

If a type, member, or initializer in the **package** must be used from `Tests/`, mark it `package`, not `internal`. Do not rely on `@testable import` to peek at internals.

## Forbidden

`@testable import` in package test targets. Tests use a normal `import` of the library product and only call `public` or `package` APIs.

## Test-only DI

In SPM packages (not app targets):

- Protocols, production adapters, and fakes are `package`, not `public`.
- Public client initializer wires production defaults.
- `package init(...)` is for tests only.
- Client-supplied dependencies stay on the public initializer; test-only seams stay on the package initializer.

Apps use the public initializer; package tests inject fakes via the package initializer without `@testable`.
