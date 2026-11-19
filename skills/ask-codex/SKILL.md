---
name: ask-codex
description: Ask Codex (OpenAI) for a second opinion, a code review, or a self-contained task, from Claude Code or the Claude desktop app. Use when the user says "ask codex", "get codex's take", "have codex review this", "hand this to codex", or "both of you look at this".
---

# ask-codex

Calls the local Codex CLI headless (`codex exec`) and brings its answer back.
The mirror skill is `ask-claude`. Both are installed everywhere by tlnstack, so
the same call works in the desktop apps, the CLIs, and T3 Code.

## Before you call

1. **Loop guard.** If `TLN_BRIDGE` is set in your environment, you are already
   the child of a bridge call. Do not call Codex back. Do the work yourself.
2. **In T3 Code**, when `delegate_task` is available, use it with a Codex
   target instead of this skill. That keeps the child visible in T3 Code.
3. **Only when asked**, or when the user's instructions call for a
   second model (council, a review gate). Never on every change.

## Pick the config

Match the caller's side, so a hub session stays on the hub and a desktop app
stays native:

```bash
case "${CLAUDE_CONFIG_DIR:-}" in
  *-hub) export CODEX_HOME="$HOME/.codex-hub" ;;   # CLI proxy on the Pi
  *)     unset CODEX_HOME ;;                       # native ~/.codex (desktop apps)
esac
```

## Call

Write the prompt to a file. Make it stand alone: the goal, the paths to read,
what you already ruled out, and the answer shape you want. Codex sees the repo,
not your conversation.

| Mode | When | Flags |
| --- | --- | --- |
| consult | Question, plan check, design opinion | `-s read-only` |
| review | Review a diff or branch | `-s read-only`, or `codex exec review` |
| task | Codex writes code | `-s workspace-write`, in **its own worktree** (see `git-workflow`) |

```bash
prompt=$(mktemp); out=$(mktemp)
cat > "$prompt" <<'EOF'
<goal, files to read, constraints, what to return>
EOF
TLN_BRIDGE=1 codex exec --json -C "$PWD" -s read-only \
  -c model_reasoning_effort=high -o "$out" - < "$prompt" \
  | python3 -c 'import json,sys;[print("codex session:",e["thread_id"]) for e in map(json.loads,sys.stdin) if e.get("type")=="thread.started"]'
cat "$out"
```

- Model: Codex's configured default unless the user names one (`-m <model>`).
- Effort: `high` for review and design, `medium` for quick questions.
- Long tasks take minutes. Run the command in the background and wait for it
  to finish. Don't poll it or call `sleep`.
- The call needs network and writes to `~/.codex`. If your shell is sandboxed,
  ask for the permission to run it unsandboxed.

## Follow up

Keep talking to the same Codex session instead of starting over:

```bash
TLN_BRIDGE=1 codex exec resume -o "$out" <session-id> "<follow-up>"
```

## Report

- Say it came from Codex. Quote or summarize its answer in a short block.
- Add your own view: where you agree, where you don't, and why. Don't apply
  Codex's changes or advice blindly. Check them like any other review.
- For task mode, review its diff in the worktree before you commit anything.
