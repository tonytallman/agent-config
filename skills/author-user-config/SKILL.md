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

**Never** treat `~/.cursor/skills`, `~/.agents/skills`, `~/.claude/skills`, `~/.cursor/rules`, `~/.claude/rules`, or `~/.codex/AGENTS.md` as source of truth. Those are install targets only (except the installed `agent-config` rules pointer).

## After writing

1. Run `<clone>/scripts/install.sh` to sync skills and the rules pointer for Cursor, Claude, and Codex.
2. Do not commit unless the user asks.
3. When they do, commit **in the agent-config clone**, not in whichever app repo was open.

## User rules vs skills

Prefer a skill (on-demand via description). If guidance must be always-on:

1. Write `rules/<name>.md` here.
2. Run install once if the rules pointer is not yet installed; adding another rule file does not require reinstall.
3. Re-run install after moving the clone so the pointer path stays correct.

## Skill quality

- Description: third person, what + when, trigger keywords.
- Keep `SKILL.md` under 500 lines.
- Omit Cursor-only frontmatter (`disable-model-invocation`, `paths`, `icon`) on user skills unless deliberately needed elsewhere.

See [AGENTS.md](../../AGENTS.md) in this repo when working inside the clone.
