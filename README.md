# agent-config

Portable user-level **Agent Skills** and rules for Cursor, Claude Code, Codex, and other [Agent Skills](https://agentskills.io/specification)-compatible tools.

## Source of truth

This git repository is the canonical location. Do **not** edit `~/.cursor/skills`, `~/.agents/skills`, or `~/.claude/skills` directly — those are install targets.

| Path | Purpose |
|------|---------|
| `skills/<name>/SKILL.md` | User skills (Agent Skills spec) |
| `rules/<name>.md` | User rules in git; paste into Cursor Settings → User Rules when always-on |
| `scripts/install.sh` | Copy skills into home-dir load paths |

Default clone location: `~/Projects/agent-config`.

## Install

After clone, pull, or authoring a new skill:

```bash
./scripts/install.sh
```

Copies each skill folder to:

- `~/.agents/skills/` — Cursor, Codex, shared/Xcode-compatible
- `~/.claude/skills/` — Claude Code
- `~/.cursor/skills/` — Cursor fallback

Uses **copy** (rsync), not symlinks — Cursor has historically failed to discover symlinked user skills after restart.

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
