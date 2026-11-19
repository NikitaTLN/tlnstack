# Claude and Codex together

I work in three apps: **T3 Code**, the **Claude desktop app**, and the **Codex
desktop app**. In each one, Claude can ask Codex and Codex can ask Claude.

## How it works

| From | To | How |
| --- | --- | --- |
| Claude (desktop app, `claude` CLI) | Codex | `ask-codex` skill: runs `codex exec` headless |
| Codex (desktop app, `codex` CLI) | Claude | `ask-claude` skill: runs `claude -p` headless |
| T3 Code (either) | the other | `delegate_task` with the other provider |

Both skills live in this repo (`skills/ask-codex`, `skills/ask-claude`), so
tlnstack installs them into every skill folder that exists: the native ones
(`~/.claude/skills`, `~/.codex/skills`) and, on `alarm`, the `-hub` ones. So
every app gets the same bridge without extra setup.

Why skills and not MCP:

- `claude mcp serve` exposes Claude Code's *tools* (Read, Edit, Bash), not
  Claude as an agent that thinks. Codex would get a file editor, not a
  reviewer.
- A skill runs the real agent with its own model, effort, and session. It can
  resume that session for follow-ups.
- It is the same shape in both directions and in every app, and it lives in
  tlnstack, so updates reach every machine with `git pull`.

## Rules (also in `agents/AGENTS.md`)

- **One hop.** The caller sets `TLN_BRIDGE=1`; a child that sees it never calls
  back. No Claude → Codex → Claude loops.
- **Same side.** Native by default. A hub caller on `alarm` calls the hub
  (`CODEX_HOME` / `CLAUDE_CONFIG_DIR` set to the `-hub` folder). The Mac has no
  hub (the proxy is paused), so it is always native there.
- **Read-only by default.** Consult and review modes can't write. Task mode
  writes only in the child's own worktree. The caller reviews the diff before
  committing.
- **Pin the model on Claude.** `ask-claude` always passes `--model opus`.
  The native `~/.claude` default can be Fable, which needs extra usage credits.
- **Only when asked**, or for council. Not on every change.
- **Report both voices.** Say which model said what, then the caller's own view.

## Modes

| Mode | Codex flags | Claude flags |
| --- | --- | --- |
| consult / review | `-s read-only` | `--permission-mode plan` |
| task (writes code) | `-s workspace-write` in a worktree | `--permission-mode acceptEdits` + `--allowedTools` in a worktree |
| follow-up | `codex exec resume <id> "<msg>"` | `claude -p --resume <id> "<msg>"` |

The commands are in each skill's `SKILL.md`.

## Optional: OpenAI's Claude Code plugin

OpenAI publishes [`codex-plugin-cc`](https://github.com/openai/codex-plugin-cc)
for Claude Code: `/codex:review`, `/codex:adversarial-review`, `/codex:rescue`,
and an optional Stop-hook review gate. It is a good extra on the Claude side,
but it is Claude-only and has no mirror in Codex, so it is not the default
bridge. To install it in a Claude session:

```text
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

Leave the review gate off unless I ask for it. It runs Codex on every Claude
reply.

## Plans

Claude Max ($100) and ChatGPT Pro ($100), each about 5x the $20 plan. That is
enough for regular cross-reviews. Check live usage with `/status` in Codex and
`/usage` in Claude.

## Verify

Run on each machine after setup:

```bash
d=$(mktemp -d) && cd "$d" && git init -q && echo 'def add(a,b): return a-b' > m.py
TLN_BRIDGE=1 codex exec -s read-only "Bug in m.py? One sentence." 2>/dev/null
TLN_BRIDGE=1 claude -p --model opus --permission-mode plan "Bug in m.py? One sentence."
```

Both should point at the minus sign.
