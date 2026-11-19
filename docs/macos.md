# macOS on the MacBook Air

`alarm` is an **Apple MacBook Air (13-inch, M2, 2022)**. It dual-boots:

| Partition | Size | System | Role |
| --- | --- | --- | --- |
| APFS (`nvme0n1p2`) | 145 GB | macOS | **Main system from now on.** Xcode and iOS work need it. |
| ext4 `asahi-root` | 80 GB | Arch Linux ARM (Asahi + Omarchy) | Host `alarm`. Kept for now; 94 % full. |

On Tailscale, the macOS side has an old node, `macbook-air-nikita`, last seen
about a year ago. Sign it back in. It is the same laptop as `alarm`, but the
other OS.

macOS cannot read the Linux ext4 partition, and Linux cannot write the APFS
one. Anything that only lives on the Linux disk has to go through GitHub or
the network. See [Moving data](#moving-data).

## Prompt for the Mac setup agent

Start a coding session in Claude Desktop or Codex on macOS and give it this:

```text
Set up this Mac from https://github.com/NikitaTLN/tlnstack. Clone it to
~/Projects/tlnstack if needed, read AGENTS.md, and carry out docs/macos.md
and docs/projects.md. Restore all eight repos, dependencies, open PR
worktrees, staged personal files and T3 settings. Build TLN2Code for Apple
Silicon, add the projects and project scripts, and verify Claude and Codex
in both directions with native sign-in. The CLI proxy is paused.

The private staging folder is pi@raspberrypi:migration/ over Tailscale SSH.
Use the restore paths in the guide. Keep staged local Git work available
for recovery and ask before applying it to an active checkout. Preserve
existing Mac files and leave the Pi copy in place until I verify the Mac.
Handle sign-ins, sudo, and macOS dialogs with me when needed, then continue
with the remaining steps. Keep secrets out of chat and Git.
```

## What is already in the cloud

Every project is on GitHub and listed in [`projects.tsv`](../projects.tsv).
`restore-projects` clones them all, runs their setup, and recreates a worktree
for each open PR. Details: [`projects.md`](projects.md).

| Thing | Where | On macOS |
| --- | --- | --- |
| tlnstack (this repo) | `NikitaTLN/tlnstack` | clone, bootstrap |
| `onlytuz`, `t3code` (TLN2Code), `Nikitway`, `voxtype-flow`, `Textio`, `NikitaTLN`, `OD-Overlay-Website` | GitHub | `restore-projects --setup --worktrees` |
| Third-party skills | `t3dotgg/tstack`, `mattpocock/skills` | cloned by the bootstrap |
| Upstream T3 Code | the Raspberry Pi | already running; reach it over Tailscale |
| Claude / ChatGPT accounts | Anthropic, OpenAI | sign in to the desktop apps |

## What is NOT in the cloud

Move these before you depend on macOS. The snapshot is from 2026-11-19; re-run
the check below for a fresh list.

| Thing | Path on `alarm` | Size | Action |
| --- | --- | --- | --- |
| onlydrafts handoff docs | `~/Projects/onlydrafts-website-handoff` | 3 MB | Restore from the Pi snapshot. |
| Obsidian vault | `~/ObsidianVault` | 46 MB | Restore from the Pi snapshot and review any differences from Obsidian Sync. |
| Codex working files | `~/Documents/Codex` | 47 MB | Copy the files. Local provider session logs are separate. |
| Notes, pictures, reports | `~/newideas.md`, `~/overlayfeatureidea.md`, `~/Pictures`, `~/reports` | about 450 MB staged | Restore from the Pi snapshot. |
| SSH keys and config | `~/.ssh` (GitHub, Pi, hosthatch, Nikitway deploy, OD SFTP) | — | Copy over SSH, or make new keys and authorize them. Never commit. |
| onlytuz release token | `~/Projects/onlytuz/publish.token` | — | **Secret.** Copy over SSH. Never commit. |
| T3 Code settings | `~/.t3/userdata` (settings, keybindings, themes) | small | Export with `t3-portable-settings` (see [`projects.md`](projects.md#2-t3-code-data-t3)). |
| T3 Code threads | `~/.t3/userdata/statev2.sqlite` | 360 MB | Stays on Linux. Threads that must survive a reboot belong on the Pi's T3 server. |
| mise tool list | `~/.config/mise/config.toml` | — | Copy. |
| Local Git work | onlytuz backup and integration branches, onlytuz and TLN2Code stashes, onlytuz and OD-Overlay-Website edits | small | [Recover from the private snapshot](projects.md#4-local-git-work). |

Check for unpushed work in any repo:

```bash
for r in ~/Projects/*/ ~/OD-Overlay-Website; do
  case "$r" in *-worktrees/) continue ;; esac
  [ -e "$r/.git" ] || { echo "NOT GIT  $r"; continue; }
  echo "== $r"
  git -C "$r" status --short | head -5
  git -C "$r" log --branches --not --remotes --oneline | head -5
  git -C "$r" stash list | head -3
done
```

## Moving data

The two systems can't share a disk. The 2026-11-19 snapshot is on the Pi in
`~/migration`, accessible only to its `pi` account. It contains the personal
files, T3 settings, and local Git backups. SSH private keys and the release
token are still on `alarm`. Use Tailscale SSH for the transfer, then authorize
a new deployment key or arrange a separate secure transfer if needed.

To refresh the files and T3 settings on `alarm` before a later switch:

```bash
ssh pi 'umask 077; mkdir -p ~/migration && chmod 700 ~/migration'
rsync -a --exclude=.venv --exclude=__pycache__ --exclude=node_modules --exclude=.git \
  ~/Projects/onlydrafts-website-handoff \
  ~/ObsidianVault ~/Documents/Codex ~/Pictures ~/reports \
  ~/newideas.md ~/overlayfeatureidea.md ~/.config/mise/config.toml pi:migration/
~/Projects/tlnstack/scripts/t3-portable-settings ~/t3-settings && rsync -a ~/t3-settings pi:migration/
```

On macOS, after signing in to Tailscale:

```bash
mkdir -p -m 700 ~/migration
rsync -a --ignore-existing pi@raspberrypi:migration/ ~/migration/
rsync -aicn pi@raspberrypi:migration/ ~/migration/   # review any differences

mkdir -p ~/Projects ~/Documents ~/.config/mise
rsync -a --ignore-existing ~/migration/onlydrafts-website-handoff ~/Projects/
rsync -a --ignore-existing ~/migration/Codex ~/Documents/
rsync -a --ignore-existing ~/migration/{ObsidianVault,Pictures,reports} ~/
rsync -a --ignore-existing ~/migration/{newideas.md,overlayfeatureidea.md} ~/
rsync -a --ignore-existing ~/migration/config.toml ~/.config/mise/
```

Review any conflicting Mac copies before merging them, especially Obsidian
files and the mise config. The `t3-settings/` folder is used in step 8. Keep
the `local-work/` folder as a backup until you decide which changes to resume.

## Setup checklist

Follow this checklist after starting the setup agent. The Mac's login, Xcode
and permission dialogs may need your input.

**No CLI proxy on the Mac.** The hub is paused. Skip every `-hub` step: no
`~/.claude-hub`, no `~/.codex-hub`, no bearer token. Claude and Codex sign in
natively everywhere on the Mac.

### 1. macOS basics

- Update macOS. Sign in with your Apple ID.
- If `git` prompts for Apple's Command Line Tools when cloning tlnstack, install
  them and retry the clone.
- **Xcode** from the App Store, then:

  ```bash
  sudo xcode-select -s /Applications/Xcode.app
  sudo xcodebuild -license accept
  xcodebuild -runFirstLaunch
  xcodebuild -downloadPlatform iOS        # simulator runtime
  ```

- In Xcode, open **Settings → Accounts** and add your Apple ID. A free account
  can run apps on your own iPhone. TestFlight and the App Store need the
  Apple Developer Program ($99 a year).

### 2. Homebrew and the tools

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"     # Apple Silicon; also add in ~/.zprofile
brew install git gh mise bash python jq ripgrep rust
brew install --cask tailscale-app
```

- `bash`: macOS ships bash 3.2; `tlnstack` needs bash 4 or newer.
- `rust`: the T3 Code fork's macOS build needs it.
- Add `~/.local/bin` and `~/.local/share/mise/shims` to `PATH` in `~/.zprofile`
  so login shells can find the agent CLIs. Activate mise in `~/.zshrc`
  (`eval "$(mise activate zsh)"`).

### 3. Tailscale

Open Tailscale and sign in. Re-authorize `macbook-air-nikita`. Check that
`ssh pi@raspberrypi true` works (Tailscale SSH: no key needed). Then pull the
staged files from the Pi ([Moving data](#moving-data)) and run `mise install`
to install `claude`, `codex`, `node`, and `opencode` from the restored config.

### 4. GitHub and tlnstack

```bash
gh auth login --git-protocol https     # HTTPS, like the existing remotes
gh auth setup-git
mkdir -p ~/Projects && cd ~/Projects
[ -d tlnstack/.git ] || gh repo clone NikitaTLN/tlnstack
cd tlnstack && ./scripts/bootstrap.sh
```

The bootstrap links the instructions and skills (symlinks, same as Linux).
Restore the [Git preferences](projects.md#git-preferences) that are unset on
the Mac.

### 5. Native sign-in for the CLIs

```bash
claude        # sign in with Claude Max, then /exit
codex login   # sign in with ChatGPT Pro
```

Check that both CLIs are signed in with the native accounts before testing
the desktop bridge.

### 6. Desktop apps (native sign-in)

| App | Get it | Sign in | Reads |
| --- | --- | --- | --- |
| Claude | claude.ai/download | Claude Max | `~/.claude/CLAUDE.md`, `~/.claude/skills` |
| Codex | the Codex app for macOS (OpenAI) | ChatGPT Pro | `~/.codex/AGENTS.md`, `~/.codex/skills` |

Homebrew can install the apps with `brew install --cask claude codex-app`.

tlnstack has linked the instructions and skills into both. Restart any app
that was open before bootstrap. Check that Claude is on your Max account,
then select Opus in its settings.

Both apps can call each other through the `ask-codex` and `ask-claude` skills.
See [`claude-codex.md`](claude-codex.md).

### 7. All projects

```bash
curl -fsSL https://vite.plus | bash         # vp, for the T3 Code fork (brings its own Node)
command -v vp                               # start a new login shell if the installer changed PATH
restore-projects --check --setup --worktrees
restore-projects --setup --worktrees
```

This clones every project in [`projects.tsv`](../projects.tsv) into
`~/Projects`, runs each one's setup (`npm ci`, `vp i`, the fork's `upstream`
remote, a Python venv), and makes a worktree for each open PR from the same
repository. For deploys, check the credentials listed in
[`projects.md`](projects.md#files-that-are-not-in-git).

### 8. T3 Code (TLN2Code fork, macOS build)

Put the exported settings in place **before the first launch**:

```bash
mkdir -p -m 700 ~/.t3/userdata
rsync -a --ignore-existing ~/migration/t3-settings/ ~/.t3/userdata/
```

Then build and install:

```bash
cd ~/Projects/t3code                        # cloned on `personal` by restore-projects
vp run dist:desktop:dmg:arm64
```

- The build is unsigned by default. That is fine for your own Mac. In-app
  browser passkeys only work in a signed build (`--signed`, which needs a
  Developer ID and `T3CODE_APPLE_TEAM_ID`).
- Open the `.dmg` and drag T3 Code to Applications. If macOS says it is
  damaged, run `xattr -cr "/Applications/T3 Code.app"`.
- The exported settings already enable the native **Claude** (`claudeAgent`)
  and **Codex** (`codex`) instances. Don't add hub instances.
- Add the projects and the TLN 2 Code scripts listed in
  [`projects.md`](projects.md#t3-code-projects-to-add-on-the-mac).
- Re-enter the OpenRouter voice key in Settings if you use cloud dictation.
- Link the Pi as an environment in T3 Code for threads that must survive a
  reboot into Linux.
- For each nightly, follow [`updating.md`](updating.md) §4, but build with
  `dist:desktop:dmg:arm64` in place of the AppImage step. The Linux-only
  variables (`T3CODE_DESKTOP_GLIBC_CEILING`, `TMPDIR`) are not needed on macOS.

### 9. Verify

```bash
tlnstack --check && tstack-sync --check      # all current
restore-projects --check --worktrees         # every project "fetch", every PR worktree "current"
claude --version && codex --version
```

Then run the bridge check in [`claude-codex.md`](claude-codex.md#verify).
In each desktop app, ask it to consult the other on a throwaway example.
In T3 Code, confirm the eight projects, TLN2Code scripts, native providers,
and Raspberry Pi environment link. Check that the expected personal files
open and that T3 Code starts successfully before removing any backup.

## iOS work with agents

- Agents build and test from the terminal: `xcodebuild -scheme <s> -destination
  'platform=iOS Simulator,name=<device>' build test`, and drive simulators with
  `xcrun simctl` (`xcrun simctl list devices` shows the names).
- Keep the Xcode project in git. Commit `.xcodeproj` / `.xcworkspace` but not
  `DerivedData` or `xcuserdata`.
- Your iPhone 15 Pro is on the tailnet for device tests.

## Disk space

145 GB is tight: Xcode is about 40 GB and each simulator runtime is about
8 GB. Clean up with `xcrun simctl delete unavailable` and by deleting
`~/Library/Developer/Xcode/DerivedData`.

Once macOS has everything and Linux is no longer needed, the 80 GB Asahi
partition can be removed and given back to macOS. Follow the Asahi Linux
uninstall guide. Don't do it until the "not in the cloud" table is empty.
