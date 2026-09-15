---
name: new-local-swift-package
description: >-
  Workflow for adding a new local Swift package to an Xcode app project. Use
  when creating a local SPM package, Package.swift, logic vs view package
  templates, or adding package targets to the app xcodeproj.
---

# New local Swift package

When creating a local Swift package in an Xcode app project:

1. Discover the project's local-packages directory (common names: `local packages/`, `Packages/`, `Modules/`).
2. Create the package at `<local-packages>/<PackageName>/`.
3. If the project provides templates, choose one: **logic** vs **view** package. Replace every placeholder in `Package.swift`.
4. Keep package entries alphabetized in the project navigator when the project follows that convention.
5. Add new package targets to the app Xcode project (discover `.xcodeproj` from the repo).
6. Register each `.testTarget` from the package's `Package.swift` in the app scheme's Test action. For each test target, add a `TestableReference` with `ReferencedContainer = container:<relative-package-path>` (e.g. `container:Packages/MyPackage`). Discover the scheme name and packages directory from the repo.
7. Ask only if package type or project-specific structure is still unclear after inspecting the repo.

Do not hard-code directory or template paths — read them from the current project.
