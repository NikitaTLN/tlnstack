# New machine setup

Give a fresh machine this repo and an agent, and it comes out configured the same
way as the others. This is the checklist, in order.

## 0. What the machine needs first

Install these, then continue. Versions are the ones on `alarm`; newer is fine.
**On macOS**, follow [`macos.md`](macos.md) instead; it covers Homebrew, Xcode,
bash 4, and the desktop apps.

| Tool | Why | Install |
| --- | --- | --- |
| `git` | clone and sync | package manager |
| `gh` | GitHub auth, PRs | package manager, then `gh auth login` |
| `node` + `npm` | the projects | package manager or `mise` |
| `python3` | scripts | package manager |
| `claude` | Claude Code | `npm i -g @anthropic-ai/claude-code` |
| `codex` | Codex | `npm i -g @openai/codex` |
| `opencode` | OpenCode | `npm i -g opencode-ai` |
| T3 Code | the control surface | the app, then link the machine |
| Claude desktop app | Claude, native sign-in | claude.ai/download (macOS, Windows) |
| Codex desktop app | Codex, native sign-in | OpenAI's Codex app |

Sign in to Tailscale so the CLI proxy on `raspberrypi` and the other machines
are reachable.

## 1. Clone this repo

```bash
mkdir -p ~/Projects && cd ~/Projects
gh repo clone NikitaTLN/tlnstack
cd tlnstack
```

If `gh` is not authenticated yet, run `gh auth login` first.

## 2. Run the bootstrap

```bash
./scripts/bootstrap.sh
```

It does all of this, idempotently:

1. Set the global git identity if it is unset.
2. Clone `t3dotgg/tstack` to `~/.local/share/tstack`.
3. Clone `mattpocock/skills` to `~/.local/share/mattpocock-skills`.
4. Install the `tstack-sync` script to `~/.local/share/tstack-sync/sync.sh`.
5. Install `tlnstack` to `~/.local/bin/tlnstack` and `tstack-sync` to
   `~/.local/bin/tstack-sync`.
6. Run `tlnstack sync` to install the instructions and personal skills.
7. Run `tstack-sync` to install Theo's skills.

Make sure `~/.local/bin` is on `PATH`. Add it if the shell profile does not:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## 3. Install the instructions and skills

If you did not run the bootstrap, do it by hand:

```bash
~/Projects/tlnstack/scripts/tlnstack --check   # see what will change
~/Projects/tlnstack/scripts/tlnstack           # write it
```

This installs:

| Source | Target |
| --- | --- |
| `agents/AGENTS.md` | `~/.claude/CLAUDE.md` |
| `agents/AGENTS.md` | `~/.claude-hub/CLAUDE.md` |
| `agents/AGENTS.md` | `~/.codex/AGENTS.md` |
| `agents/AGENTS.md` | `~/.codex-hub/AGENTS.md` |
| `agents/AGENTS.md` | `~/.config/opencode/AGENTS.md` |
| `skills/<name>/` | `~/.claude/skills/<name>` and the other three skill folders |

A target that already has local edits is left alone and reported; re-run with
`--force` to overwrite it. Backups go to
`~/.local/state/tlnstack-sync/backups/`.

On Linux and macOS, `tlnstack` links each target to this repo (one source of
truth); `git pull` is then enough to update it. On Windows it copies. Pass `--link` or
`--copy` to force either mode. `--capture` is only useful in copy mode; on a
linked machine, edits land in the repo directly.

## 4. Hub configuration (paused: skip it)

The CLI proxy is paused as of 2026-11-19. **Don't set it up on a new
machine.** Sign in natively instead (`claude`, `codex login`, the desktop
apps). The rest of this section is kept for when the proxy comes back.

Claude Code and Codex each have two configs: the **native** one
(`~/.claude`, `~/.codex`) signed in to Claude and ChatGPT directly, and the
**hub** one (`~/.claude-hub`, `~/.codex-hub`) that routes through the CLI proxy
on the Raspberry Pi. tlnstack installs the instructions and skills into both.
Only the hub configs carry the proxy settings and the bearer token, so they are
not in this repo. Set them up per machine:

- `~/.claude-hub/settings.json` — `ANTHROPIC_BASE_URL` set to
  `https://raspberrypi.tailadf79f.ts.net:8317` and the auth token.
- `~/.codex-hub/config.toml` — `model_provider = "cliproxy"` with
  `base_url = "https://raspberrypi.tailadf79f.ts.net:8317/v1"`.

Get the token from an existing machine or from the credential store (see
`docs/credentials.md`). Never commit it. `docs/machines.md` has the full paths.

## 5. Projects and T3 Code settings

```bash
gh auth setup-git
restore-projects --setup --worktrees
```

Clones every project in `projects.tsv`, runs its setup, and makes a worktree
per open PR. Files git doesn't hold, the T3 Code settings export, and the
other things to carry are in [`projects.md`](projects.md).

## 6. Install the remaining skills

- **Claude plugin skills** install themselves when Claude Code starts, from the
  plugin marketplace, into `~/.claude/skills/synced`.
- **Omarchy skills** (`diagnose-crash`, `omarchy`) come with Omarchy on a Linux
  desktop, as symlinks into `~/.local/share/omarchy/default/agents/skills`.
- **The Matt Pocock library** is cloned by the bootstrap and read on demand. No
  install step; the installed `AGENTS.md` describes the triggers.

## 7. T3 Code secrets

In T3 Code, open **Settings → Secrets** on the machine running the server. From
then on, agents call `request_secret` instead of asking in chat. See
`docs/credentials.md`.

## 8. Verify

```bash
tlnstack --check          # every target should say current
tstack-sync --check       # every tstack skill should say current
```

Then start each harness once and confirm it picks up the instructions:

| Harness | Check |
| --- | --- |
| Claude Code | `claude` prints no error; it reads `~/.claude/CLAUDE.md` |
| Codex | `codex` reads `~/.codex/AGENTS.md` |
| OpenCode | reads `~/.config/opencode/AGENTS.md` |
| Claude desktop app | the skill list shows `ask-codex` |
| Codex desktop app | the skill list shows `ask-claude` |

Then run the bridge check in [`claude-codex.md`](claude-codex.md#verify).

## Keeping a machine current

```bash
cd ~/Projects/tlnstack && git pull && tlnstack sync
tstack-sync
```

Or, in an agent, say **"update tlnstack"** or **"update tstack"**; the
`tlnstack-sync` and `tstack-sync` skills do it.

## Changing the shared setup

Edit `agents/AGENTS.md` or a skill **in this repo**, never an installed copy.
On Linux and macOS the installed files are symlinks, so the change is live;
commit and push, and other machines pick it up with `git pull`. On Windows, run
`tlnstack sync` after the change. See the repo `AGENTS.md`.
