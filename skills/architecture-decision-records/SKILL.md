---
name: architecture-decision-records
description: >-
  Writes or updates Architecture Decision Record files under docs/adr/ using the
  project filename, template, and status workflow. Use when the user mentions ADRs,
  docs/adr/, superseding an ADR, or has agreed to record a design decision.
---

# Architecture Decision Records (ADR)

Use when writing or updating an ADR file — not to decide whether a decision deserves one (project rules may handle that).

## File location and naming

- **Directory**: `docs/adr/` at the repository root unless the project already uses another ADR location — follow the existing convention.
- **Name**: `NNNN-short-title-in-kebab-case.md` where `NNNN` is zero-padded decimal order (e.g. `0001`, `0002`). Use the next free number.
- **One decision per file** unless superseding requires explicit linkage.

## Document template

```markdown
# N. Short title

- **Status**: Proposed | Accepted | Deprecated | Superseded
- **Date**: YYYY-MM-DD
- **Supersedes**: (optional) link to older ADR filename
- **Superseded by**: (optional) leave empty until replaced

## Context

Problem, constraints, and relevant options.

## Decision

Chosen approach in plain language.

## Consequences

**Positive**: Benefits.

**Negative**: Trade-offs or accepted costs.

**Risks / follow-ups**: Things to monitor or do next.
```

## Status workflow

1. **Proposed** — under review or not yet reflected fully in code.
2. **Accepted** — agreed; implementation may still be in progress.
3. **Deprecated** — no longer recommended; keep file for history.
4. **Superseded** — another ADR replaces this one; link both ways.

When superseding, create a new numbered file. Update the old file's status and links rather than rewriting history.

## Process checklist

1. Allocate the next `NNNN` in `docs/adr/`.
2. Copy the template and fill Context, Decision, and Consequences with concrete terms.
3. Set Status and Date.
4. Land it with the related change when practical, or in a small follow-up if discovered late.

Link related ADRs, issues, or PRs in Context or Consequences.
