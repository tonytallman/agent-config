---
name: error-presentation
description: >-
  Presents Swift errors in logs and UI without localizedDescription: interpolate
  \(error) for logging, authored user copy for primary UI, optional details
  disclosure for diagnostics. Use when handling Error, localizedDescription,
  error alerts, user-facing error messages, logging errors, LocalizedError, or
  errorDescription.
---

# Error presentation

Follow the **error-presentation** user rule. This skill expands the pattern.

## Why not localizedDescription

For Swift `Error` values that do not conform to `LocalizedError`, `localizedDescription` is Foundation’s generic fallback (“The operation couldn’t be completed. (Module.Error error 0.)”). That string is weak for logs and is not acceptable as primary user-facing copy.

## Logging

Interpolate the error value:

```swift
logger.error("Saving profile failed: \(error)")
```

String interpolation prints the error’s type, case name, and associated values—what you want in diagnostics. If the project’s logger uses privacy annotations (e.g. `os.Logger`), apply them to interpolated values as the API requires; do not switch to `localizedDescription` for readability.

## User-facing copy

The app authors the message. Say **what happened** and **what the user can do next** (retry, check the connection, contact support, fix input).

- Tie copy to the **operation** that failed and, when useful, to **known error cases** the feature handles.
- Do not put error-derived text in an alert title, alert message, toast, banner, or inline label.

Map errors to presentation in the view model or a small presenter at the composition root—not by reading `localizedDescription` at the view layer.

## Details disclosure

Optional, visually secondary diagnostics use the same text you would log: `String(describing: error)` or `\(error)` in a string. Never use `localizedDescription` here either.

Example (SwiftUI):

```swift
struct SaveFailedSheet: View {
    let userMessage: String
    let recoveryHint: String
    let error: Error

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(userMessage)
                .font(.headline)
            Text(recoveryHint)
            DisclosureGroup("Details") {
                Text(String(describing: error))
                    .font(.caption)
                    .textSelection(.enabled)
            }
        }
        .padding()
    }
}
```

The sheet’s `userMessage` and `recoveryHint` are authored strings; `error` is only inside the disclosure.

## Also off-limits

- `(error as NSError).localizedDescription`
- `LocalizedError.errorDescription`, `failureReason`, or `recoverySuggestion` as primary UI copy
- Adding `LocalizedError` on an error type only so descriptions look presentable in the UI

## Exceptions

Use `localizedDescription` or `LocalizedError` only when the user explicitly asks, or when a system API requires `LocalizedError`. Say so in the response instead of working around it silently.
