#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="${ROOT}/skills"

DESTS=(
  "${HOME}/.agents/skills"
  "${HOME}/.claude/skills"
  "${HOME}/.cursor/skills"
)

if [[ ! -d "${SKILLS_SRC}" ]]; then
  echo "error: ${SKILLS_SRC} not found" >&2
  exit 1
fi

for dest in "${DESTS[@]}"; do
  mkdir -p "${dest}"
done

shopt -s nullglob
for skill_dir in "${SKILLS_SRC}"/*/; do
  name="$(basename "${skill_dir}")"
  if [[ ! -f "${skill_dir}/SKILL.md" ]]; then
    echo "warning: skipping ${name} (no SKILL.md)" >&2
    continue
  fi
  for dest in "${DESTS[@]}"; do
    rsync -a --delete "${skill_dir%/}" "${dest}/${name}/"
  done
  echo "installed ${name}"
done

echo "done: skills copied to ~/.agents/skills, ~/.claude/skills, ~/.cursor/skills"
