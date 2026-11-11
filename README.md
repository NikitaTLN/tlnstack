# tlnstack

My personal agent stack: the global instructions, the personal skills, and the
machine setup that every harness on every machine gets. Clone it on a new
machine, run the bootstrap, and the machine is configured the same way.

It is a dotfiles-style repo. It tracks `main` directly, on purpose.

## What is here

| Path | What it is |
| --- | --- |
| `agents/AGENTS.md` | The canonical global instructions. One file, installed to Claude Code, Codex, OpenCode, and both hub folders. |
| `skills/` | My personal skills, installed into every skill folder. |
| `docs/` | The long version: workflow, git, credentials, machines, skills, T3 Code, new-machine setup. |
| `scripts/tlnstack` | Installs and syncs the instructions and skills. |
| `scripts/tstack-sync.sh` | Keeps the third-party `t3dotgg/tstack` skills up to date. |
| `scripts/bootstrap.sh` | Sets up a fresh machine in one go. |
| `AGENTS.md` / `CLAUDE.md` | Instructions for an agent working **on this repo**. |

## Quick start on a new machine

```bash
mkdir -p ~/Projects && cd ~/Projects
gh repo clone NikitaTLN/tlnstack
cd tlnstack && ./scripts/bootstrap.sh
```

Full checklist: [`docs/new-machine.md`](docs/new-machine.md).

## Everyday use

```bash
tlnstack --check     # show what would change
tlnstack             # install / update the instructions and skills
tlnstack --capture   # pull a local edit back into this repo
tstack-sync          # update Theo's skills from upstream
```

To change the shared setup: edit `agents/AGENTS.md` or a skill **in this repo**,
run `tlnstack sync`, commit, and push. Do not edit an installed copy directly.

## The stack

- **Harnesses**: Claude Code (native `~/.claude`, or hub `~/.claude-hub` through
  the CLI proxy), Codex (native `~/.codex`, or hub `~/.codex-hub`), OpenCode
  (native). The proxy is the Raspberry Pi on port 8317.
- **Skills**: mine (`skills/` here), Theo's (`t3dotgg/tstack`), Matt Pocock's
  (`mattpocock/skills`), plus the Claude plugin skills and Omarchy's.
- **Credentials**: agents use T3 Code's secret store first, never a chat ask.
  See [`docs/credentials.md`](docs/credentials.md).
- **Git**: branch, worktree, PR, merge, release. See
  [`docs/git.md`](docs/git.md) and the `git-workflow` skill.

## Docs

| Doc | Topic |
| --- | --- |
| [`docs/workflow.md`](docs/workflow.md) | How I work, end to end. |
| [`docs/git.md`](docs/git.md) | Branches, worktrees, PRs, releases. |
| [`docs/credentials.md`](docs/credentials.md) | The secret-store rule and the sudo case. |
| [`docs/machines.md`](docs/machines.md) | Machines and paths. |
| [`docs/skills.md`](docs/skills.md) | Every skill and where it comes from. |
| [`docs/t3-code.md`](docs/t3-code.md) | The T3 Code features used by default. |
| [`docs/new-machine.md`](docs/new-machine.md) | Setting up a fresh machine. |

## License

MIT. See [`LICENSE`](LICENSE).
