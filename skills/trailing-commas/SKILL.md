---
name: trailing-commas
description: >-
  Requires trailing commas in multiline Swift comma-separated lists per SE-0439.
  Use when editing Swift code, formatting lists, or when the user mentions trailing
  commas, multiline parameters, array literals, or Swift 6.1 list syntax.
compatibility: Swift 6.1+ for full SE-0439 trailing-comma coverage
---

# Trailing commas

End every **multiline** comma-separated list with a trailing comma wherever Swift permits it ([SE-0439](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0439-trailing-comma-lists.md)). Single-line lists omit it.

## Allowed (required when multiline)

- `(...)` — tuples and tuple patterns; parameter and argument lists of functions, initializers, subscripts (including key-path subscripts), enum associated values, expression macros, and attributes; string interpolation arguments
- `[...]` — array literals, dictionary literals, closure capture lists
- `<...>` — generic parameter and argument lists

## Not allowed

Swift rejects a trailing comma everywhere else. Never add one to: `if` / `guard` / `while` condition lists, enum case label lists, `switch` case labels, inheritance clauses, generic `where` clauses, non-list attribute arguments (`@inline(never,)`), or empty lists.

## Example

```swift
func connect(
    id: UUID,
    timeout: Duration,
) async throws { }
```

When editing existing multiline lists, add trailing commas as part of the change rather than leaving mixed formatting.
