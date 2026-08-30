#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="${ROOT}/skills"
RULES_DIR="${ROOT}/rules"

SKILL_DESTS=(
  "${HOME}/.agents/skills"
  "${HOME}/.claude/skills"
  "${HOME}/.cursor/skills"
)

POINTER_START='<!-- agent-config:rules:start -->'
POINTER_END='<!-- agent-config:rules:end -->'

pointer_body() {
  cat <<EOF
Read and follow all rules from \`${RULES_DIR}\`. When writing new rules or updating rules, use the same location.
EOF
}

install_rules_pointer() {
  local body
  body="$(pointer_body)"

  mkdir -p "${HOME}/.agents/rules" "${HOME}/.claude/rules" "${HOME}/.cursor/rules"
  printf '%s\n' "${body}" > "${HOME}/.agents/rules/agent-config.md"
  printf '%s\n' "${body}" > "${HOME}/.claude/rules/agent-config.md"

  cat > "${HOME}/.cursor/rules/agent-config.mdc" <<EOF
---
alwaysApply: true
---

${body}
EOF

  local codex_agents="${HOME}/.codex/AGENTS.md"
  local codex_dir="${HOME}/.codex"
  mkdir -p "${codex_dir}"

  local managed_block
  managed_block="$(cat <<EOF
${POINTER_START}

${body}

${POINTER_END}
EOF
)"

  local codex_tmp="${codex_dir}/AGENTS.md.tmp"
  if [[ -f "${codex_agents}" ]] && grep -Fq "${POINTER_START}" "${codex_agents}"; then
    local before after
    before="$(awk -v start="${POINTER_START}" '$0 == start { exit } { print }' "${codex_agents}")"
    after="$(awk -v end="${POINTER_END}" 'found { print } $0 == end { found = 1 }' "${codex_agents}")"
    {
      [[ -n "${before}" ]] && printf '%s\n\n' "${before}"
      printf '%s\n' "${managed_block}"
      [[ -n "${after}" ]] && printf '\n%s' "${after}"
    } > "${codex_tmp}"
    mv "${codex_tmp}" "${codex_agents}"
  elif [[ -f "${codex_agents}" ]]; then
    printf '\n%s\n' "${managed_block}" >> "${codex_agents}"
  else
    printf '%s\n' "${managed_block}" > "${codex_agents}"
  fi

  echo "installed rules pointer -> ${RULES_DIR}"
}

if [[ ! -d "${SKILLS_SRC}" ]]; then
  echo "error: ${SKILLS_SRC} not found" >&2
  exit 1
fi

for dest in "${SKILL_DESTS[@]}"; do
  mkdir -p "${dest}"
done

shopt -s nullglob
for skill_dir in "${SKILLS_SRC}"/*/; do
  name="$(basename "${skill_dir}")"
  if [[ ! -f "${skill_dir}/SKILL.md" ]]; then
    echo "warning: skipping ${name} (no SKILL.md)" >&2
    continue
  fi
  for dest in "${SKILL_DESTS[@]}"; do
    rsync -a --delete "${skill_dir%/}" "${dest}/${name}/"
  done
  echo "installed ${name}"
done

install_rules_pointer

echo "done: skills copied to ~/.agents/skills, ~/.claude/skills, ~/.cursor/skills"
