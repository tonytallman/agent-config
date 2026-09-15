# Verify tests

A functional change is not complete until affected tests were **executed** this session and observed to pass. Evidence means command output, not reasoning.

- Never state or imply tests pass without having run them this session.
- `-only-testing:`, `--filter`, and `-skip-testing:` are for iterating on one failure. The final check must be **unfiltered**. When reporting, state the scope actually run; anything less than the full suite must name what was excluded and why.
- Never edit a scheme's test targets, or delete/disable a test, to unblock a run.
- Treat a hung or timed-out run as a **failure**, not as inconclusive. Report the last test that started.
- If tests could not be run at all, say so explicitly in the final summary with the command attempted, the failure, and which tests remain unverified.
- Never make a test pass by weakening it (removing assertions, adding sleeps, discarding stream values to realign an off-by-one). Propose such changes; do not apply them silently.
