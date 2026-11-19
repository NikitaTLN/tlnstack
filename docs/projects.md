# Projects, T3 Code data, and everything else

What I have, where it lives, and how a new machine gets it. An agent setting up
a machine runs the commands here; it doesn't need to discover anything.

## 1. Projects: one command

The list is [`projects.tsv`](../projects.tsv) (path, repo, base branch, clone
options, setup command, notes). On a new machine, after `gh auth login`:

```bash
gh auth setup-git                                 # HTTPS git uses gh's login
restore-projects --check --setup --worktrees      # dry run
restore-projects --setup --worktrees              # do it
```

It is safe to run again. For each project it:

1. clones the repo over HTTPS (or fetches it if it is already there) and checks
   out the base branch,
2. runs the project's setup (`npm ci`, `vp i`, a Python venv, the fork's
   remotes),
3. creates a worktree at `<repo>-worktrees/<branch>` for every **open PR**
   (merged branches are skipped), and runs setup in it.

It never deletes, resets, or switches the branch of an existing checkout.

| Project | Repo | Base | Stack | macOS notes |
| --- | --- | --- | --- | --- |
| `tlnstack` | NikitaTLN/tlnstack | `main` | bash, Markdown | Cloned first, by hand. |
| `onlytuz` | 9kantawis/onlytuz | `main` | Tauri + Vite + TS | UI dev works on macOS. Releases still build on the Windows PC. |
| `t3code` | NikitaTLN/TLN2Code | `personal` | Electron, Vite+ (`vp`) | Build the app with `vp run dist:desktop:dmg:arm64`. |
| `Nikitway` | Nikitway/Nikitway-Website | `chore/import-project` | Astro + PHP | `npm ci` in `nikitway-site/`. |
| `voxtype-flow` | NikitaTLN/voxtype-flow | `main` | Linux desktop app | Linux-only. The code is cloned; it does not run on macOS. |
| `Textio` | NikitaTLN/Textio | `main` | not started | Brief in `PROMPT.md`. |
| `NikitaTLN` | NikitaTLN/NikitaTLN | `main` | Markdown | GitHub profile. |
| `OD-Overlay-Website` | NikitaTLN/OD-Overlay-Website | `main` | static site + Python | Moves to `~/Projects/` on the Mac (it was `~/` on `alarm`). |

To add a project, add a line to `projects.tsv` (tab-separated) and commit.

### Files that are not in git

The script can't fetch these. Copy them by hand over SSH (see `macos.md`,
"Moving data"). Never commit them.

| File | Project | What it is |
| --- | --- | --- |
| `publish.token` | onlytuz | **Secret.** Release publishing token. |
| `~/.ssh/od-overlay-website` | OD-Overlay-Website | SFTP deploy key. |
| `~/.ssh/id_ed25519_hosthatch*` | Nikitway | Server keys (hosthatch VPS). |
| `.local/fresh-work/` | OD-Overlay-Website | Scratch folder. Optional. |

## 2. T3 Code data (`~/.t3`)

| Path | Size | What it is | New machine |
| --- | --- | --- | --- |
| `userdata/settings.json` | small | Server settings: providers, default model, favorites, thread-title rules, theme | **Export** with `t3-portable-settings` |
| `userdata/client-settings.json` | small | UI: fonts (DM Sans), speech words, browser and diff prefs | **Export** (as is) |
| `userdata/keybindings.json` | small | 88 bindings, using `mod`, so they work on macOS | **Export** (as is) |
| `userdata/themes/` | small | `macos-tahoe`, `omarchy-apple-glass` | **Export** (as is) |
| `userdata/statev2.sqlite` | 360 MB | Threads and projects, with Linux paths | Stays. Threads that must persist go on the Pi's T3 server. |
| `userdata/secrets/` | small | This server's signing keys, cloud link key, voice API key | Stays. The new server makes its own keys. Re-enter the OpenRouter voice key in Settings. |
| `userdata/logs/`, `browser-artifacts/`, `attachments/` | 360 MB | Logs and thread files | Stays. |
| `worktrees/onlytuz/t3-*` | 650 MB | T3-made worktrees (`t3/*` branches) | Stays. Their commits are on GitHub. |
| `tools/`, `runtime/`, `caches/`, `bin/` | 1.1 GB | Linux binaries (headless Chrome, cloudflared), app runtime | Stays. T3 downloads its own on macOS. |
| `scratch/`, `dev/` | small | Scratch threads, dev-server data | Stays. |

Export on `alarm` and copy before T3 Code first starts on the Mac:

```bash
# on alarm
~/Projects/tlnstack/scripts/t3-portable-settings ~/t3-settings
rsync -a ~/t3-settings pi:migration/
# on the Mac, before the first T3 Code launch (Tailscale SSH, no key needed)
mkdir -p ~/.t3/userdata && rsync -a pi@raspberrypi:migration/t3-settings/ ~/.t3/userdata/
```

The export turns on the native Claude (`claudeAgent`) and Codex (`codex`)
providers, moves the default model (Opus 5.5, effort high) and favorites to
them, and drops the hub, the Codex API instance, the CLI-proxy usage source, and
saved secrets.

### T3 Code projects to add on the Mac

Add these in T3 Code after `restore-projects` has run. Skip the old junk
projects on `alarm` (`Downloads`, `t3-0.0.44-linux-arm64`, `18`, `w1dget`,
`Work`, omarchy `bin`).

| Project | Path | Settings |
| --- | --- | --- |
| TLN 2 Code | `~/Projects/t3code` | Icon: monogram "T2", fuchsia. New threads: worktree. Scripts below. |
| onlytuz | `~/Projects/onlytuz` | — |
| Nikitway | `~/Projects/Nikitway` | — |
| tlnstack | `~/Projects/tlnstack` | — |
| Textio, NikitaTLN, OD-Overlay-Website, voxtype-flow | `~/Projects/<name>` | — |

TLN 2 Code project scripts:

| Name | Command | When |
| --- | --- | --- |
| Dev | `vp run dev` | manual |
| Setup Worktree | `node scripts/setup-worktree.ts` | on worktree create |
| Check changes | `vp run check:changed origin/personal` | manual |
| Latest upstream nightly | `node scripts/personal-fork.mjs nightly` | manual |

## 3. Everything else

| Thing | Where on `alarm` | New machine |
| --- | --- | --- |
| Tool versions | `~/.config/mise/config.toml` (`claude`, `codex`, `node`, `opencode` at `latest`) | Copy, then `mise install`. |
| Git settings | `~/.gitconfig`: aliases `co/br/ci/st`, `pull.rebase`, `push.autoSetupRemote`, `rerere`, histogram diff | Re-create with `git config --global` (don't copy the file: the `gh` path differs). |
| SSH hosts | `~/.ssh/config`: `pi`, `alarm`, `omarchy`, `w1dget` | Copy with the keys. |
| Obsidian vault | `~/ObsidianVault/Main Vault` (46 MB) | Obsidian Sync if it is on, else copy. |
| Notes and pictures | `~/newideas.md`, `~/overlayfeatureidea.md`, `~/Pictures`, `~/reports`, `~/Documents/Codex` | Copy. |
| Other agent CLIs | `~/.local/bin`: `copilot`, `gemini`, `grok`, `crush`, `pi`, `omp`, `ghui`, `hunk` | Optional. Ask before installing. |
| Linux desktop | Omarchy, Hyprland, Waybar scripts, `voxtype`, `brightness-control` | Linux-only. Don't port. |

## 4. Leftovers to decide on before leaving Linux

Re-check with the loop in `macos.md` ("What is NOT in the cloud").

| Repo | Leftover | Default if not decided |
| --- | --- | --- |
| onlytuz | Local-only branches: `backup/column-resize-pre-rebase` (3), `backup/relative-lap-coloring-before-base-refresh-20261111` (1), `backup/twitch-auth-delivery-before-base-20261111` (1), `integration/shiftlight-profiles` (3), `integration/shiftlight-style` (1) | Stay on Linux (backups and trial merges). |
| onlytuz | Uncommitted `src/lib/miva.ts` on `main`; stash "trackmap WIP" (2026-10-04) | Stay on Linux. |
| OD-Overlay-Website | Staged `site/index.html` on `chore/record-publish-20261105` | Stays on Linux. |
