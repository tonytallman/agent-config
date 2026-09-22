# agent-config

Portable user-level **Agent Skills** and rules for Cursor, Claude Code, Codex, and other [Agent Skills](https://agentskills.io/specification)-compatible tools.

## Source of truth

This git repository is the canonical location. Do **not** edit `~/.cursor/skills`, `~/.agents/skills`, or `~/.claude/skills` directly — those are install targets.

| Path | Purpose |
|------|---------|
| `skills/<name>/SKILL.md` | User skills (Agent Skills spec) |
| `rules/<name>.md` | User rules in git |
| `exports/cursor-account-user-rules.md` | Account User Rules export for Cursor cloud sync |
| `scripts/install.sh` | Copy skills and rules to platform install targets |

Default clone location: `~/Projects/agent-config`.

## Install

After clone, pull, or authoring a new skill or rule:

```bash
./scripts/install.sh
```

### Skills

Copies each skill folder (with `SKILL.md`) to:

- `~/.agents/skills/` — Cursor, Codex, shared/Xcode-compatible
- `~/.claude/skills/` — Claude Code
- `~/.cursor/skills/` — Cursor (synced to Cloud Agents when **Sync Skills for Cloud Agents** is enabled)

Stale destination folders without a matching repo skill are pruned. Install fails if any copied skill is missing `SKILL.md`.

Uses **copy** (rsync), not symlinks — Cursor has historically failed to discover symlinked user skills after restart.

### Cursor rules (local + cloud)

For each `rules/<name>.md`, install writes `~/.cursor/rules/<name>.mdc` with `alwaysApply: true` and the **full rule body** (copy, not symlink). Also writes `~/.cursor/rules/agent-config.mdc` as a meta rule (repo is source of truth; GitHub fallback when the clone path is unavailable).

**Re-run install after rule changes** so local Cursor copies stay current.

File-based `~/.cursor/rules` do not sync to Cloud Agents. For cloud, paste `exports/cursor-account-user-rules.md` into **Cursor → Customize → Rules** (account User Rules). Regenerate that export with install whenever rules change.

### Other platforms (Claude, agents, Codex)

Installs a **rules pointer** (`agent-config`) that includes the local `rules/` path when readable, plus a GitHub repo fallback when not (e.g. cloud VMs):

- `~/.claude/rules/agent-config.md` — Claude Code
- `~/.agents/rules/agent-config.md` — shared
- `~/.codex/AGENTS.md` — managed block for Codex

### Cloud Agents checklist

After install:

1. Enable **Settings → Agents → Sync Skills for Cloud Agents** (syncs `~/.cursor/skills/`).
2. Paste or update account User Rules from `exports/cursor-account-user-rules.md` into **Customize → Rules**.
3. Re-run `./scripts/install.sh` after moving the clone or editing rules.

Restart the IDE or start a new agent session if skills do not appear immediately.

## Adding a user skill or rule

Use the **author-user-config** skill, or see [AGENTS.md](AGENTS.md).

Briefly: write under `skills/` or `rules/` in this repo, run `./scripts/install.sh`, then commit here (not in the app repo you had open).

## Project vs user

- **User skills** (this repo): apply across all projects after install.
- **Project skills/rules**: live in each app repo under `.cursor/skills/` or `.cursor/rules/`.

## Validation

```bash
npx --yes skills-ref validate ./skills/<skill-name>
```
