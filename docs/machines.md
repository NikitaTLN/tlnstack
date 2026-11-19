# Machines

Tailnet: `tailadf79f.ts.net` (Tailscale). MagicDNS names end in
`.tailadf79f.ts.net`.

| Machine | OS | User | Role | MagicDNS |
| --- | --- | --- | --- | --- |
| `macbook-air-nikita` | macOS (Apple Silicon M2) | — | **Main system** on the MacBook Air. Xcode/iOS, T3 Code (TLN2Code), Claude and Codex desktop apps. Same laptop as `alarm`. | `macbook-air-nikita.tailadf79f.ts.net` |
| `alarm` | Arch Linux ARM (Asahi, aarch64) | `w1dget` | The Linux side of the MacBook Air (dual boot). T3 Code (TLN2Code AppImage), Claude Code, Codex, OpenCode. | `alarm.tailadf79f.ts.net` |
| `w1dget` | Windows | `nikit` | Windows PC for `onlytuz` native builds and iRacing tests. | `w1dget.tailadf79f.ts.net` |
| `raspberrypi` | Linux (Ubuntu, aarch64) | `pi` | CLI proxy hub. Serves Claude Code and Codex on port `8317` (https). Runs upstream T3 Code (nightly) as a service, Claude Code, Codex, tlnstack, tstack. | `raspberrypi.tailadf79f.ts.net` |
| `omarchy-1` | Linux | — | Secondary Linux box. | `omarchy-1.tailadf79f.ts.net` |
| `iphone-15-pro` | iOS | — | T3 Code mobile client. | — |

`alarm` and `macbook-air-nikita` are one MacBook Air (13-inch, M2, 2022), so
only one is online at a time. macOS setup: [`macos.md`](macos.md).

Other tailnet devices (`nixos-btw`, `desktop-rhpcebo`, `omarchy`) are not part
of the current stack.

## Paths

Linux (`alarm`):

| Thing | Path |
| --- | --- |
| Claude Code native config | `~/.claude/CLAUDE.md`, `~/.claude/settings.json` |
| Claude Code hub (CLI proxy) | `~/.claude-hub/CLAUDE.md`, `~/.claude-hub/settings.json` |
| Codex native config | `~/.codex/AGENTS.md`, `~/.codex/config.toml` |
| Codex hub (CLI proxy) | `~/.codex-hub/AGENTS.md`, `~/.codex-hub/config.toml` |
| OpenCode global config | `~/.config/opencode/AGENTS.md` |
| Skills | `~/.claude/skills`, `~/.claude-hub/skills`, `~/.codex/skills`, `~/.codex-hub/skills` |
| tstack clone | `~/.local/share/tstack` |
| tstack-sync | `~/.local/share/tstack-sync/sync.sh` |
| Matt Pocock library | `~/.local/share/mattpocock-skills` |
| tlnstack (this repo) | `~/Projects/tlnstack` |
| T3 Code data | `~/.t3/userdata` |
| Projects | `~/Projects` |
| T3 Code personal fork | `~/Projects/t3code` (`personal` branch, published nightlies) |
| T3 Code task worktrees | `~/Projects/t3code-worktrees/<branch>` |

macOS (`macbook-air-nikita`): the same paths as Linux under `~`, plus:

| Thing | Path |
| --- | --- |
| Claude desktop app | `/Applications/Claude.app`, reads `~/.claude` (native) |
| Codex desktop app | `/Applications/Codex.app`, reads `~/.codex` (native) |
| T3 Code (TLN2Code build) | `/Applications/T3 Code.app` |
| Xcode | `/Applications/Xcode.app`, data in `~/Library/Developer` |
| Homebrew | `/opt/homebrew` |

Windows (`w1dget`):

| Thing | Path |
| --- | --- |
| `onlytuz` main checkout | `C:/Users/nikit/Projects/onlyoverlays` |
| `onlytuz` worktrees | `C:/Users/nikit/Projects/onlyoverlays-worktrees/<branch>` |
| PowerShell `npm` shim | `npm.cmd` (`npm.ps1` is blocked) |

## CLI proxy hub

The `-hub` folders are the configs that route through the CLI proxy. The plain
`~/.claude` and `~/.codex` are the native configs and are separate; only
`settings.json` / `config.toml` differ, not the instructions or skills.

T3 Code and the CLIs use the hub configs. The Claude and Codex desktop apps use
the native configs and sign in directly (Claude Max, ChatGPT Pro).

- Claude Code: `~/.claude-hub/settings.json` sets `ANTHROPIC_BASE_URL` to
  `https://raspberrypi.tailadf79f.ts.net:8317` and an auth token.
- Codex: `~/.codex-hub/config.toml` sets `model_provider = "cliproxy"` with
  `base_url = "https://raspberrypi.tailadf79f.ts.net:8317/v1"`.
- The bearer token is a secret. It lives only in those files on each machine and
  in the credential store. It is never committed. To set up a new machine, copy
  it from an existing machine or ask for it through the secret store
  (`docs/credentials.md`).

## Previews

`onlytuz` previews are served from the worktree containing the change, port
`1420` for the main checkout and `1421+` for worktrees, and published on the
tailnet with `tailscale serve --bg --tcp <port> tcp://127.0.0.1:<port>`. See the
repository's `AGENTS.md` for the full preview workflow.
