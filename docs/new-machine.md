# New machine setup

Give a fresh machine this repo and an agent, and it comes out configured the same
way as the others. This is the checklist, in order.

## 0. What the machine needs first

Install these, then continue. Versions are the ones on `alarm`; newer is fine.

| Tool | Why | Install |
| --- | --- | --- |
| `git` | clone and sync | package manager |
| `gh` | GitHub auth, PRs | package manager, then `gh auth login` |
| `node` + `npm` | the projects | package manager or `mise` |
| `python3` | scripts | package manager |
| `claude` | Claude Code | `npm i -g @anthropic-ai/claude-code` |
| `codex` | Codex | `npm i -g @openai/codex` |
| `opencode` | OpenCode | `npm i -g opencode-ai` |
| `op` | 1Password CLI (optional) | package manager |
| T3 Code | the control surface | the app, then link the machine |

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

On the first run, an existing file that tlnstack has never managed is taken over
(`adopt`) with a backup. After that, a hand edit is a `local-edit` and is
skipped. `tlnstack --capture` copies a hand edit back into the repo so it can be
committed.

## 4. Hub configuration

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

## 5. Install the remaining skills

- **Claude plugin skills** install themselves when Claude Code starts, from the
  plugin marketplace, into `~/.claude/skills/synced`.
- **Omarchy skills** (`diagnose-crash`, `omarchy`) come with Omarchy on a Linux
  desktop, as symlinks into `~/.local/share/omarchy/default/agents/skills`.
- **The Matt Pocock library** is cloned by the bootstrap and read on demand. No
  install step; the installed `AGENTS.md` describes the triggers.

## 6. T3 Code secrets

In T3 Code, open **Settings → Secrets** on the machine running the server. Add a
provider if 1Password is in use. From then on, agents call `request_secret`
instead of asking in chat. See `docs/credentials.md`.

## 7. Verify

```bash
tlnstack --check          # every target should say current
tstack-sync --check       # every tstack skill should say current
```

Then start each harness once and confirm it picks up the instructions:

| Harness | Check |
| --- | --- |
| Claude Code | `claude` prints no error; it reads `~/.claude-hub/CLAUDE.md` |
| Codex | `codex` reads `~/.codex-hub/AGENTS.md` |
| OpenCode | reads `~/.config/opencode/AGENTS.md` |

## Keeping a machine current

```bash
cd ~/Projects/tlnstack && git pull && tlnstack sync
tstack-sync
```

Or, in an agent, say **"update tlnstack"** or **"update tstack"**; the
`tlnstack-sync` and `tstack-sync` skills do it.

## Changing the shared setup

Edit `agents/AGENTS.md` or a skill **in this repo**, never an installed copy.
Then `tlnstack sync`, commit, push. Other machines pick it up with `git pull`
plus `tlnstack sync`. See the repo `AGENTS.md`.
