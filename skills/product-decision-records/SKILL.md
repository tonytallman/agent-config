---
name: product-decision-records
description: >-
  Writes or updates Product Decision Record files under docs/pdr/ and keeps
  docs/requirements.md as the living product spec. Use when the user mentions
  PDRs, docs/pdr/, product decisions, living requirements, or docs/requirements.md.
---

# Product Decision Records (PDR)

Use when writing or updating a PDR file or the living requirements spec — not to decide whether a decision deserves one (project rules may handle that).

PDRs record *what the product is* and why. Architecture Decision Records (ADRs) under `docs/adr/` record *how we build it*. Do not put product vocabulary or product requirement choices in ADRs.

## Living requirements

- **File**: `docs/requirements.md` at the repository root’s `docs/` unless the project already uses another path — follow the existing convention.
- This file is the **current** accepted (and proposed/later) requirements. **Edit in place**; git history is the changeset log.
- A PDR is not the spec. After accepting a PDR that changes product intent, update `docs/requirements.md` and list affected IDs under the PDR’s **Affects**.
- Spec-only edits are fine when there were no meaningful alternatives. Write a PDR when alternatives existed and the rationale would otherwise disappear on the next spec edit.
- Link **PDR → requirement IDs**. Requirements may optionally **See** a PDR; do not maintain a dual reverse index.

### Requirement IDs and status

- Format: `REQ-<AREA>-<NNN>` (zero-padded), stable once assigned; do not reuse IDs.
- Areas are project-defined (e.g. `UI`, `MET`); extend as needed.
- Status: `Proposed` | `Accepted` | `Later` | `Deprecated`. MVP vs later is status on the requirement, not a second file.

## File location and naming (PDRs)

- **Directory**: `docs/pdr/` at the repository root unless the project already uses another PDR location — follow the existing convention.
- **Name**: `NNNN-short-title-in-kebab-case.md` where `NNNN` is zero-padded decimal order (e.g. `0001`, `0002`). Use the next free number.
- **One decision per file** unless superseding requires explicit linkage.

## Document template

```markdown
# N. Short title

- **Status**: Proposed | Accepted | Deprecated | Superseded
- **Date**: YYYY-MM-DD
- **Supersedes**: (optional) link to older PDR filename
- **Superseded by**: (optional) leave empty until replaced
- **Affects**: (optional) requirement IDs this decision motivated or changed

## Context

Problem, constraints, and relevant options.

## Decision

Chosen approach in plain language.

## Consequences

**Positive**: Benefits.

**Negative**: Trade-offs or accepted costs.

**Risks / follow-ups**: Things to monitor or do next (including updating docs/requirements.md).
```

## Status workflow

1. **Proposed** — under review or not yet reflected in the living spec.
2. **Accepted** — agreed; requirements and/or vision docs should reflect it.
3. **Deprecated** — no longer recommended; keep file for history.
4. **Superseded** — another PDR replaces this one; link both ways.

When superseding, create a new numbered file. Update the old file's status and links rather than rewriting history.

## Process checklist

1. Allocate the next `NNNN` in `docs/pdr/`.
2. Copy the template and fill Context, Decision, and Consequences with concrete terms.
3. Set Status and Date; list **Affects** when requirement IDs exist.
4. Update `docs/requirements.md` (and vision docs if product language changed) when the decision is Accepted.
5. Land the PDR with the related change when practical, or in a small follow-up if discovered late.

Link related PDRs, ADRs, issues, or PRs in Context or Consequences when helpful.
