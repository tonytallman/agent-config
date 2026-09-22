# Maintaining agent-config

This repository holds **user-level** skills and rules. Agents working in this repo should follow these conventions.

## Layout

```
skills/<name>/SKILL.md              # Agent Skills spec; folder name must match `name` frontmatter
rules/<name>.md                     # Plain markdown user rules (optional)
exports/cursor-account-user-rules.md # Generated; paste into Cursor account User Rules for cloud sync
scripts/install.sh                  # Sync skills; copy Cursor rules; install pointers elsewhere
```

## Authoring user skills

1. Create `skills/<kebab-name>/SKILL.md` with YAML frontmatter: required `name` and `description` (what + when, third person).
2. Keep `SKILL.md` under 500 lines. Omit Cursor-only fields (`disable-model-invocation`, `paths`, `icon`) unless needed for a deliberate project skill elsewhere.
3. Run `./scripts/install.sh`.
4. Commit in **this** repo when the user asks — not in unrelated app repos.

Never use `~/.cursor/skills` as the source of truth for new user skills.

## Authoring user rules

Prefer a skill unless guidance must be always-on. For always-on rules:

1. Write `rules/<name>.md` here (plain markdown).
2. Run `./scripts/install.sh` after adding or changing rules.
   - **Cursor:** copies full rule bodies to `~/.cursor/rules/<name>.mdc` (local always-on rules).
   - **Cloud:** update account User Rules from `exports/cursor-account-user-rules.md` (Customize → Rules).
   - **Claude/agents/Codex:** pointer with local path + GitHub fallback.

Install may copy rule bodies into `~/.cursor/rules/` as the Cursor install target; the repo remains source of truth. Do not edit those copies directly — change `rules/` here and re-run install.

Never treat `~/.claude/rules`, `~/.agents/rules`, or `~/.codex/AGENTS.md` as source of truth — except the installed `agent-config` pointer itself.

## Promoting from a project

When guidance applies to all Swift/app projects, generalize examples (drop project-specific type names), move to `skills/`, delete the project copy, run install.

## Do not

- Put this repo root at `~/.agents/skills` (README/scripts would be scanned as skills).
- Symlink skill folders into home directories.
- Add git submodules of this repo into app projects.
