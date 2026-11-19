---
name: ask-claude
description: Ask Claude (Anthropic) for a second opinion, a code review, or a self-contained task, from Codex or the Codex desktop app. Use when the user says "ask claude", "get claude's take", "have claude review this", "hand this to claude", or "both of you look at this".
---

# ask-claude

Calls the local Claude Code CLI headless (`claude -p`) and brings its answer
back. The mirror skill is `ask-codex`. Both are installed everywhere by
tlnstack, so the same call works in the desktop apps, the CLIs, and T3 Code.

## Before you call

1. **Loop guard.** If `TLN_BRIDGE` is set in your environment, you are already
   the child of a bridge call. Do not call Claude back. Do the work yourself.
2. **In T3 Code**, when `delegate_task` is available, use it with a Claude
   target instead of this skill. That keeps the child visible in T3 Code.
3. **Only when asked**, or when the user's instructions call for a
   second model (council, a review gate). Never on every change.

## Pick the config

Match the caller's side, so a hub session stays on the hub and a desktop app
stays native:

```bash
case "${CODEX_HOME:-}" in
  *-hub) export CLAUDE_CONFIG_DIR="$HOME/.claude-hub" ;;   # CLI proxy on the Pi
  *)     unset CLAUDE_CONFIG_DIR ;;                        # native ~/.claude (desktop apps)
esac
```

## Call

Write the prompt to a file. Make it stand alone: the goal, the paths to read,
what you already ruled out, and the answer shape you want. Claude sees the
repo, not your conversation.

| Mode | When | Flags |
| --- | --- | --- |
| consult | Question, plan check, design opinion | `--permission-mode plan` |
| review | Review a diff or branch | `--permission-mode plan` |
| task | Claude writes code | `--permission-mode acceptEdits` plus `--allowedTools` for the checks it must run, in **its own worktree** (see `git-workflow`) |

```bash
prompt=$(mktemp)
cat > "$prompt" <<'EOF'
<goal, files to read, constraints, what to return>
EOF
TLN_BRIDGE=1 claude -p --model opus --effort high --output-format json \
  --permission-mode plan < "$prompt" \
  | python3 -c 'import json,sys;d=json.load(sys.stdin);print("claude session:",d.get("session_id"));print(d.get("result"))'
```

- Model: always pass `--model`. The native config's default may be a model
  that needs extra usage credits. Use `opus` unless the user names another.
- Effort: `high` for review and design, `medium` for quick questions.
- Long tasks take minutes. Run the command in the background and wait for it
  to finish. Don't poll it or call `sleep`.
- The call needs network and writes to `~/.claude`. If your shell is sandboxed,
  ask for the permission to run it unsandboxed.

## Follow up

Keep talking to the same Claude session instead of starting over:

```bash
TLN_BRIDGE=1 claude -p --resume <session-id> --model opus --output-format json "<follow-up>"
```

## Report

- Say it came from Claude. Quote or summarize its answer in a short block.
- Add your own view: where you agree, where you don't, and why. Don't apply
  Claude's changes or advice blindly. Check them like any other review.
- For task mode, review its diff in the worktree before you commit anything.
