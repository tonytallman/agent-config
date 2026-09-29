# Error presentation

When handling a Swift `Error` in logs or UI:

- Do not read `localizedDescription` for logs or user-facing copy.
- Logs: interpolate the error value (`\(error)`).
- UI: write what happened and how to proceed. Put the error text only in an optional details disclosure, using `\(error)`.
- For the pattern, follow the **error-presentation** skill.
