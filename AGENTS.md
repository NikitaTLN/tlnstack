# tlnstack (this repo)

Instructions for an agent working **on this repository**. The global
instructions that this repo *installs* are in `agents/AGENTS.md`; do not confuse
the two.

## What this repo is

My personal agent stack. It is a dotfiles-style repo: it tracks `main` directly,
with no task branches, and the normal never-commit-to-`main` rule does not apply
here. Edit, sync, commit, push.

`agents/AGENTS.md` is the canonical global instruction file. It is installed,
unchanged, to every harness:

| Target | Harness |
| --- | --- |
| `~/.claude/CLAUDE.md` | Claude Code |
| `~/.claude-hub/CLAUDE.md` | Claude Code (hub) |
| `~/.codex/AGENTS.md` | Codex |
| `~/.codex-hub/AGENTS.md` | Codex (hub) |
| `~/.config/opencode/AGENTS.md` | OpenCode |

`skills/<name>/` installs into the four skill folders
(`~/.claude/skills`, `~/.claude-hub/skills`, `~/.codex/skills`,
`~/.codex-hub/skills`).

## Layout

| Path | What it is |
| --- | --- |
| `agents/AGENTS.md` | The canonical global instructions. |
| `skills/` | Personal skills (`git-workflow`, `redo`, `browser-report`, `tstack-sync`, `tlnstack-sync`, `ask-codex`, `ask-claude`). |
| `scripts/tlnstack` | The sync CLI. |
| `scripts/tstack-sync.sh` | The third-party tstack skill sync. |
| `scripts/bootstrap.sh` | Fresh-machine setup. |
| `projects.tsv`, `scripts/restore-projects` | The project list and the script that clones and sets them up. Add new projects here. |
| `scripts/t3-portable-settings` | T3 Code settings export for a new machine. |
| `docs/` | The long-form docs. Keep them in step with `agents/AGENTS.md`. |

## The loop for changing the setup

1. Edit `agents/AGENTS.md` or a skill here. Never edit an installed copy.
2. `./scripts/tlnstack --check` then `./scripts/tlnstack` to install it here. On
   Linux and macOS the installed files are symlinks, so the edit is live; the sync just
   records it.
3. `./scripts/tstack-sync.sh --check` if a third-party skill changed.
4. Update the matching doc under `docs/` if behaviour changed.
5. Commit on `main` with a conventional message and push.

## Rules

- Never commit a secret. Hub bearer tokens, `~/.codex/auth.json`,
  `~/.t3/userdata/secrets/`, `publish.token`, and `*.env` with real values stay
  out. See `docs/credentials.md`.
- Scripts run on Linux, macOS (bash 4+ from Homebrew, BSD tools), and Git Bash
  on Windows. No GNU-only flags without a fallback.
- Keep `agents/AGENTS.md` harness-agnostic: no Claude-only or Codex-only tool
  names outside the T3 Code section, which is explicitly about T3 Code.
- One canonical copy. If a rule belongs to everyone, it goes in
  `agents/AGENTS.md`; if it is long, it goes in `docs/` and `agents/AGENTS.md`
  points at it.
- Personal settings for third-party skills (council members, PR style) live in
  `agents/AGENTS.md`, so the skills themselves can be updated from upstream
  without losing them.
