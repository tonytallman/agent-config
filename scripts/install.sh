#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="${ROOT}/skills"
RULES_DIR="${ROOT}/rules"
EXPORTS_DIR="${ROOT}/exports"
GITHUB_REPO="https://github.com/tonytallman/agent-config"
GITHUB_RULES_URL="${GITHUB_REPO}/tree/main/rules"
GITHUB_SKILLS_URL="${GITHUB_REPO}/tree/main/skills"

SKILL_DESTS=(
  "${HOME}/.agents/skills"
  "${HOME}/.claude/skills"
  "${HOME}/.cursor/skills"
)

CURSOR_RULES_DEST="${HOME}/.cursor/rules"

POINTER_START='<!-- agent-config:rules:start -->'
POINTER_END='<!-- agent-config:rules:end -->'

pointer_body() {
  if [[ -d "${RULES_DIR}" && -r "${RULES_DIR}" ]]; then
    cat <<EOF
Read and follow all rules from \`${RULES_DIR}\`. When writing new rules or updating rules, use the same location.

If the local clone is unavailable (e.g. on a Cursor Cloud Agent VM), fetch and follow rules from ${GITHUB_RULES_URL} and relevant skills from ${GITHUB_SKILLS_URL}.
EOF
  else
    cat <<EOF
The agent-config clone is not available at \`${RULES_DIR}\`.

Fetch and follow rules from ${GITHUB_RULES_URL} and relevant skills from ${GITHUB_SKILLS_URL}. When editing rules, update the git repository at ${GITHUB_REPO} and re-run install.
EOF
  fi
}

cursor_meta_rule_body() {
  cat <<EOF
This repository (\`${ROOT}\`) is the source of truth for user-level skills and rules.

- Edit skills under \`skills/\` and rules under \`rules/\` in the clone, then re-run \`./scripts/install.sh\`.
- Do not treat install targets (\`~/.cursor/skills\`, \`~/.cursor/rules\`, etc.) as source of truth.

If this clone path is unavailable (e.g. on a Cursor Cloud Agent VM), fetch and follow:

- Rules: ${GITHUB_RULES_URL}
- Skills: ${GITHUB_SKILLS_URL}

For cloud agents, also paste rules from \`exports/cursor-account-user-rules.md\` into Cursor **Customize → Rules**, and enable **Settings → Agents → Sync Skills for Cloud Agents** after install.
EOF
}

write_mdc_rule() {
  local dest_file="$1"
  local body_file="$2"

  {
    printf '%s\n' '---'
    printf '%s\n' 'alwaysApply: true'
    printf '%s\n' '---'
    printf '\n'
    cat "${body_file}"
  } > "${dest_file}"
}

install_cursor_rules() {
  mkdir -p "${CURSOR_RULES_DEST}"

  shopt -s nullglob
  local rule_file name
  for rule_file in "${RULES_DIR}"/*.md; do
    name="$(basename "${rule_file}" .md)"
    write_mdc_rule "${CURSOR_RULES_DEST}/${name}.mdc" "${rule_file}"
    echo "installed cursor rule ${name}.mdc"
  done

  local meta_tmp
  meta_tmp="$(mktemp)"
  cursor_meta_rule_body > "${meta_tmp}"
  write_mdc_rule "${CURSOR_RULES_DEST}/agent-config.mdc" "${meta_tmp}"
  rm -f "${meta_tmp}"
  echo "installed cursor rule agent-config.mdc (meta)"

  for mdc_file in "${CURSOR_RULES_DEST}"/*.mdc; do
    name="$(basename "${mdc_file}" .mdc)"
    [[ "${name}" == "agent-config" ]] && continue
    if [[ ! -f "${RULES_DIR}/${name}.md" ]]; then
      rm -f "${mdc_file}"
      echo "pruned stale cursor rule ${name}.mdc"
    fi
  done
}

generate_account_rules_export() {
  mkdir -p "${EXPORTS_DIR}"
  local export_file="${EXPORTS_DIR}/cursor-account-user-rules.md"

  {
    cat <<'HEADER'
# Cursor account User Rules (agent-config)

Paste this into **Cursor → Customize → Rules** so rules sync to Cloud Agents.
Regenerate with `./scripts/install.sh` after rule changes.

---

HEADER

    shopt -s nullglob
    local rule_file name
    for rule_file in "${RULES_DIR}"/*.md; do
      name="$(basename "${rule_file}" .md)"
      printf '## %s\n\n' "${name}"
      cat "${rule_file}"
      printf '\n\n---\n\n'
    done
  } > "${export_file}"

  echo "generated ${export_file}"
}

install_rules_pointer() {
  local body
  body="$(pointer_body)"

  mkdir -p "${HOME}/.agents/rules" "${HOME}/.claude/rules"
  printf '%s\n' "${body}" > "${HOME}/.agents/rules/agent-config.md"
  printf '%s\n' "${body}" > "${HOME}/.claude/rules/agent-config.md"

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

  if [[ -d "${RULES_DIR}" && -r "${RULES_DIR}" ]]; then
    echo "installed rules pointer -> ${RULES_DIR} (with GitHub fallback)"
  else
    echo "installed rules pointer -> ${GITHUB_REPO} (local clone unavailable)"
  fi
}

verify_skill_install() {
  shopt -s nullglob
  local skill_dir name dest
  for skill_dir in "${SKILLS_SRC}"/*/; do
    name="$(basename "${skill_dir}")"
    [[ -f "${skill_dir}/SKILL.md" ]] || continue
    for dest in "${SKILL_DESTS[@]}"; do
      if [[ ! -f "${dest}/${name}/SKILL.md" ]]; then
        echo "error: missing ${dest}/${name}/SKILL.md after install" >&2
        exit 1
      fi
    done
  done
}

prune_stale_skills() {
  local dest installed_dir name
  for dest in "${SKILL_DESTS[@]}"; do
    [[ -d "${dest}" ]] || continue
    shopt -s nullglob
    for installed_dir in "${dest}"/*/; do
      name="$(basename "${installed_dir}")"
      if [[ ! -f "${SKILLS_SRC}/${name}/SKILL.md" ]]; then
        rm -rf "${installed_dir}"
        echo "pruned stale ${dest}/${name}"
      fi
    done
  done
}

print_post_install_checklist() {
  cat <<EOF

Post-install checklist (Cursor Cloud Agents):
  1. Enable Settings → Agents → Sync Skills for Cloud Agents.
  2. Paste or update account User Rules from:
       ${EXPORTS_DIR}/cursor-account-user-rules.md
     (Cursor → Customize → Rules) after rule changes.
  3. Re-run ./scripts/install.sh after moving the clone or editing rules.

EOF
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
    rsync -a --delete "${skill_dir%/}/" "${dest}/${name}/"
  done
  echo "installed skill ${name}"
done

prune_stale_skills
verify_skill_install

install_cursor_rules
install_rules_pointer
generate_account_rules_export

echo "done: skills copied to ~/.agents/skills, ~/.claude/skills, ~/.cursor/skills"
echo "done: cursor rules copied to ~/.cursor/rules/*.mdc"

print_post_install_checklist
