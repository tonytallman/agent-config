# Cursor account User Rules (agent-config)

Paste this into **Cursor → Customize → Rules** so rules sync to Cloud Agents.
Regenerate with `./scripts/install.sh` after rule changes.

---

## adaptor

# Adaptor

When bridging types at the composition root:

- If converting **one concrete source type** to a **different interface**, adapt it. Do not widen provider packages or add forbidden local dependencies to expose the target.
- If adding behavior that works on **any instance of a protocol**, decorate the instance instead. Do not use an adaptor for that.
- For the implementation, follow the **adaptor** skill.


---

## decorator

# Decorator

When adding functionality to protocol instances:

- If the new behavior works equally well on **any instance of the protocol**, decorate the instance. Do not add it to every conformer and do not subclass to intercept.
- If the behavior is specific to one concrete type, add it to that type (or extract a protocol first, then decorate).
- For the implementation, follow the **decorator** skill.


---

## squash-merge

# Squash merge

When merging a pull request on the user's behalf, squash and merge by default. Use a merge commit or rebase only if the user explicitly asks for it.


---

## verify-tests

# Verify tests

A functional change is not complete until affected tests were **executed** this session and observed to pass. Evidence means command output, not reasoning.

- Never state or imply tests pass without having run them this session.
- `-only-testing:`, `--filter`, and `-skip-testing:` are for iterating on one failure. The final check must be **unfiltered**. When reporting, state the scope actually run; anything less than the full suite must name what was excluded and why.
- Never edit a scheme's test targets, or delete/disable a test, to unblock a run.
- Treat a hung or timed-out run as a **failure**, not as inconclusive. Report the last test that started.
- If tests could not be run at all, say so explicitly in the final summary with the command attempted, the failure, and which tests remain unverified.
- Never make a test pass by weakening it (removing assertions, adding sleeps, discarding stream values to realign an off-by-one). Propose such changes; do not apply them silently.


---

