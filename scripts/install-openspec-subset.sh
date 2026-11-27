#!/usr/bin/env bash
# Symlink agent-skills into a target skills directory (default: ~/.agents/skills),
# automatically excluding the 4 skills superseded by OpenSpec workflows so upstream
# syncs stay conflict-free while OpenSpec owns spec/plan/apply/archive.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
SKILLS_SRC="${REPO_ROOT}/skills"
TARGET_DIR="${HOME}/.agents/skills"
DRY_RUN=0

EXCLUDED_SKILLS=(
  "spec-driven-development"
  "planning-and-task-breakdown"
  "idea-refine"
  "incremental-implementation"
)

usage() {
  cat <<EOF
Usage: $(basename "$0") [--target <dir>] [--dry-run] [-h|--help]

Symlink all skills from ${SKILLS_SRC} into <dir> (default: ~/.agents/skills),
skipping the 4 OpenSpec-overlapping skills:
  ${EXCLUDED_SKILLS[*]}

Options:
  --target <dir>  Target skills directory (default: ~/.agents/skills)
  --dry-run       Print actions without modifying the filesystem
  -h, --help      Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || { echo "Error: --target requires a directory argument" >&2; exit 2; }
      TARGET_DIR="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

is_excluded() {
  local candidate="$1"
  local ex
  for ex in "${EXCLUDED_SKILLS[@]}"; do
    if [[ "${candidate}" == "${ex}" ]]; then
      return 0
    fi
  done
  return 1
}

if [[ "${DRY_RUN}" -eq 0 ]]; then
  mkdir -p "${TARGET_DIR}"
fi

linked=0
skipped=0
removed=0

# Remove any existing symlinks in TARGET_DIR pointing to the excluded skills.
for ex in "${EXCLUDED_SKILLS[@]}"; do
  dest="${TARGET_DIR}/${ex}"
  if [[ -L "${dest}" ]]; then
    if [[ "${DRY_RUN}" -eq 1 ]]; then
      echo "[dry-run] rm ${dest}"
    else
      rm -f "${dest}"
    fi
    removed=$((removed + 1))
  fi
done

for skill_path in "${SKILLS_SRC}"/*; do
  [[ -d "${skill_path}" && -f "${skill_path}/SKILL.md" ]] || continue
  skill_name="$(basename "${skill_path}")"
  if is_excluded "${skill_name}"; then
    skipped=$((skipped + 1))
    continue
  fi
  dest="${TARGET_DIR}/${skill_name}"
  if [[ -e "${dest}" && ! -L "${dest}" ]]; then
    echo "Warning: skipping ${dest} (exists and is not a symlink)" >&2
    continue
  fi
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "[dry-run] ln -sfn ${skill_path} ${dest}"
  else
    ln -sfn "${skill_path}" "${dest}"
  fi
  linked=$((linked + 1))
done

echo "Done: linked=${linked}, skipped_excluded=${skipped}, removed_stale=${removed} (target: ${TARGET_DIR})"
