#!/usr/bin/env bash
# Set up a fresh machine from this repo. Idempotent: run it again to update.
#
# It clones the third-party skill sources, installs the two sync scripts into
# ~/.local/bin, then installs this repo's instructions and skills and the
# third-party tstack skills.
#
# It does not install the tools themselves or the hub bearer token. See
# docs/new-machine.md.
set -euo pipefail

self=$(readlink -f "${BASH_SOURCE[0]}")
REPO="${TLNSTACK_REPO:-$(cd "$(dirname "$self")/.." && pwd)}"
BIN_DIR="${TLNSTACK_BIN:-$HOME/.local/bin}"

TSTACK_REPO="${TSTACK_REPO:-$HOME/.local/share/tstack}"
MATT_REPO="${MATT_REPO:-$HOME/.local/share/mattpocock-skills}"
TSTACK_SYNC_DIR="${TSTACK_SYNC_DIR:-$HOME/.local/share/tstack-sync}"

log() { printf '\n== %s ==\n' "$1"; }

clone_or_pull() {
  local url="$1" dir="$2"
  if [ -d "$dir/.git" ]; then
    git -C "$dir" pull --quiet --ff-only
    echo "updated $dir"
  else
    mkdir -p "$(dirname "$dir")"
    git clone --quiet "$url" "$dir"
    echo "cloned  $dir"
  fi
}

log "git identity"
if [ -z "$(git config --global user.email || true)" ]; then
  git config --global user.name "${GIT_NAME:-Nikita Ljubimov}"
  git config --global user.email "${GIT_EMAIL:-nikitaljubimov@gmail.com}"
  echo "set global git identity"
else
  echo "global git identity already set: $(git config --global user.name) <$(git config --global user.email)>"
fi

log "third-party skill sources"
clone_or_pull https://github.com/t3dotgg/tstack "$TSTACK_REPO"
clone_or_pull https://github.com/mattpocock/skills "$MATT_REPO"

log "install the sync scripts"
mkdir -p "$TSTACK_SYNC_DIR" "$BIN_DIR"
install -m 0755 "$REPO/scripts/tstack-sync.sh" "$TSTACK_SYNC_DIR/sync.sh"
ln -sf "$TSTACK_SYNC_DIR/sync.sh" "$BIN_DIR/tstack-sync"
ln -sf "$REPO/scripts/tlnstack" "$BIN_DIR/tlnstack"
ln -sf "$REPO/scripts/codex-hub-catalog" "$BIN_DIR/codex-hub-catalog"
echo "linked  $BIN_DIR/tlnstack"
echo "linked  $BIN_DIR/tstack-sync"
echo "linked  $BIN_DIR/codex-hub-catalog"

log "install this repo's instructions and skills"
"$REPO/scripts/tlnstack"

log "install the third-party tstack skills"
"$TSTACK_SYNC_DIR/sync.sh"

log "done"
cat <<EOF
Next:
  1. Make sure $BIN_DIR is on PATH.
  2. Set up the hub config and bearer token (docs/machines.md, docs/credentials.md).
  3. Verify: tlnstack --check && tstack-sync --check
EOF
