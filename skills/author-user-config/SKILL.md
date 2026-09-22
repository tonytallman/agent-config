---
name: author-user-config
description: >-
  Authors new user-level skills and rules in the agent-config git repository,
  not in home-dir skill folders. Use when creating, updating, or promoting a
  personal all-projects skill or user rule for Cursor, Claude, Codex, or Xcode.
---

# Author user config

Use when creating, updating, moving, or promoting a **user-level** skill or rule (personal, all-projects). Do **not** use for project skills/rules in app repos.

## Resolve the clone

Default: `~/Projects/agent-config`

If missing, search for a git repo whose root contains `skills/` and `scripts/install.sh`. If still unclear, ask the user.

## Where to write

| Kind | Path | Notes |
|------|------|-------|
| User skill | `<clone>/skills/<name>/SKILL.md` | Folder name must match `name` in frontmatter ([Agent Skills spec](https://agentskills.io/specification)) |
| User rule | `<clone>/rules/<name>.md` | Plain markdown; prefer a skill unless always-on |

**Never** treat `~/.cursor/skills`, `~/.agents/skills`, `~/.claude/skills`, `~/.claude/rules`, `~/.agents/rules`, or `~/.codex/AGENTS.md` as source of truth. Those are install targets only.

For Cursor, `~/.cursor/rules/*.mdc` are also install targets (copied rule bodies). Edit `rules/` in the clone and re-run install.

## After writing

1. Run `<clone>/scripts/install.sh` to sync skills and rules to platform install targets.
2. For **Cursor Cloud Agents**: enable **Sync Skills for Cloud Agents**, and paste/update account User Rules from `exports/cursor-account-user-rules.md` when rules change.
3. Do not commit unless the user asks.
4. When they do, commit **in the agent-config clone**, not in whichever app repo was open.

## User rules vs skills

Prefer a skill (on-demand via description). If guidance must be always-on:

1. Write `rules/<name>.md` here.
2. Run install after adding or changing rules (copies to `~/.cursor/rules/`; regenerates the account User Rules export).
3. Re-run install after moving the clone.

## Skill quality

- Description: third person, what + when, trigger keywords.
- Keep `SKILL.md` under 500 lines.
- Omit Cursor-only frontmatter (`disable-model-invocation`, `paths`, `icon`) on user skills unless deliberately needed elsewhere.

See [AGENTS.md](../../AGENTS.md) in this repo when working inside the clone.
