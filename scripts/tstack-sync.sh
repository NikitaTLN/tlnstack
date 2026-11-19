#!/usr/bin/env bash
# Sync t3dotgg/tstack skills into Claude Code and Codex skill folders.
#
# Usage: tstack-sync.sh [--check]
#   --check  show what would change, write nothing to the skill folders
#
# A skill is only overwritten when its installed copy still matches what the
# last sync installed. Local edits are reported and left alone.
set -euo pipefail

REPO="${TSTACK_REPO:-$HOME/.local/share/tstack}"
STATE="${TSTACK_STATE:-$HOME/.local/state/tstack-sync}"
TARGETS=(
  "${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
  "${CLAUDE_HUB_SKILLS_DIR:-$HOME/.claude-hub/skills}"
  "${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
  "${CODEX_HUB_SKILLS_DIR:-$HOME/.codex-hub/skills}"
)
CHECK=0

for arg in "$@"; do
  case "$arg" in
    --check) CHECK=1 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

if [ ! -d "$REPO/.git" ]; then
  git clone --quiet https://github.com/t3dotgg/tstack "$REPO"
fi

before=$(git -C "$REPO" rev-parse --short HEAD)
git -C "$REPO" pull --quiet --ff-only
after=$(git -C "$REPO" rev-parse --short HEAD)
echo "upstream: $before -> $after"

# Linux has sha256sum; macOS has shasum. Same output format, same hashes.
if command -v sha256sum >/dev/null 2>&1; then SHA=(sha256sum); else SHA=(shasum -a 256); fi

tree_hash() {
  (cd "$1" && find . -type f -print0 | sort -z | xargs -0 "${SHA[@]}" | "${SHA[@]}" | cut -d' ' -f1)
}

mkdir -p "$STATE"

for src in "$REPO"/skills/*/; do
  name=$(basename "$src")
  new=$(tree_hash "$src")

  for target in "${TARGETS[@]}"; do
    if [ ! -d "$target" ]; then
      echo "skip     $name -> $target (folder missing)"
      continue
    fi

    dest="$target/$name"
    slug=$(printf '%s' "$target" | "${SHA[@]}" | cut -c1-12)
    record="$STATE/$slug-$name"

    if [ ! -e "$dest" ]; then
      action=install
    else
      cur=$(tree_hash "$dest")
      recorded=$(cat "$record" 2>/dev/null || true)
      if [ "$cur" = "$new" ]; then
        action=current
      elif [ -n "$recorded" ] && [ "$cur" = "$recorded" ]; then
        action=update
      else
        action=local-edit
      fi
    fi

    if [ "$CHECK" = 0 ]; then
      case "$action" in
        install|update)
          rm -rf "$dest"
          mkdir -p "$dest"
          cp -a "$src/." "$dest/"
          printf '%s\n' "$new" > "$record"
          ;;
        current)
          printf '%s\n' "$new" > "$record"
          ;;
      esac
    fi

    printf '%-10s %-20s %s\n' "$action" "$name" "$target"
  done
done

if [ "$CHECK" = 1 ]; then
  echo "(check only: nothing was written)"
fi
