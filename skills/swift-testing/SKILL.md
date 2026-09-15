---
name: swift-testing
description: >-
  Unit tests use Swift Testing (not XCTest), mirrored folder structure, and app
  scheme registration. Use when adding or updating test targets, @Test, #expect,
  or mirrored test files.
---

# Swift Testing

## Framework

- Use [Swift Testing](https://developer.apple.com/documentation/testing) (`import Testing`), not XCTest for new tests.
- Use `@Test`, `#expect`, and `@Suite` where appropriate.
- Name test types `{TypeUnderTest}Tests`.

## Async tests

- Do not use `Task.sleep` to synchronize a test with async work. It is a race, and it becomes a hang when the expected value never arrives.
- Use `confirmation()`, or pull the sequence deterministically, so the test blocks on the event rather than on a duration.
- Do not discard leading elements (`_ = await iterator.next()`) to skip a seeded or replayed value. If which value arrives first depends on scheduling, the discard eats the real value and the test hangs forever.
- Give suites exercising async streams a time limit (`@Suite(.timeLimit(.minutes(1)))`) so a hang fails with a test name instead of wedging the run.
- If a type cannot be tested without sleeping, that is a design signal: the type starts unstructured work with no observable completion point. Raise it rather than papering over it.

## Mirrored folder structure

- Preserve the subdirectory path of the code under test in the test target (drop only the module/source-root prefix when the project uses one).
- Prefer one mirrored test file per primary source type; append `Tests` to the filename.
- When adding, moving, or renaming source files, apply the same change to the mirrored test path.

## Scheme registration

When adding a test target in an Xcode app project, add it to the app scheme's Test action. Discover the scheme name from the current repo.

- **App/project test targets:** `ReferencedContainer = container:<App>.xcodeproj`
- **Local SPM package test targets:** `ReferencedContainer = container:<packages-dir>/<PackageName>` (e.g. `container:Packages/Metrics`). Set `BlueprintIdentifier`, `BlueprintName`, and `BuildableName` to the test target name (no `.xctest` suffix).

## Tests with functional changes

- Any change that adds, removes, or changes behavior must include corresponding unit test additions, removals, or updates in the mirrored test file.
- Exemptions: documentation-only, assets, or project config with no behavior change; pure refactors that do not alter observable behavior (existing tests must still pass).
- If a functional change does not update tests, the final summary must explicitly state why tests were not applicable.
- Treat missing or outdated tests as incomplete work.
