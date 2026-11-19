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

## What is already in the cloud

| Thing | Where | On macOS |
| --- | --- | --- |
| tlnstack (this repo) | `NikitaTLN/tlnstack` | clone, bootstrap |
| `onlytuz` | `9kantawis/onlytuz` | clone; recreate worktrees only for active branches |
| T3 Code fork | `NikitaTLN/TLN2Code` | clone, build the macOS app (below) |
| `voxtype-flow` | `NikitaTLN/voxtype-flow` | clone (Linux dictation tool; macOS has its own) |
| `Textio` | `NikitaTLN/Textio` | clone |
| `OD-Overlay-Website` | `NikitaTLN/OD-Overlay-Website` | clone |
| Profile README | `NikitaTLN/NikitaTLN` | clone if needed |
| Third-party skills | `t3dotgg/tstack`, `mattpocock/skills` | cloned by the bootstrap |
| Upstream T3 Code | the Raspberry Pi | already running; reach it over Tailscale |
| Claude / ChatGPT accounts | Anthropic, OpenAI | sign in to the desktop apps |

## What is NOT in the cloud

Move these before you depend on macOS. The snapshot is from 2026-11-19; re-run
the check below for a fresh list.

| Thing | Path on `alarm` | Size | Action |
| --- | --- | --- | --- |
| Nikitway site and brand assets | `~/Projects/Nikitway` | 293 MB (most is `node_modules`) | Make it a git repo and push it (private). |
| onlydrafts handoff docs | `~/Projects/onlydrafts-website-handoff` | 3 MB | Push it, or move it into `onlytuz/docs`. |
| Obsidian vault | `~/ObsidianVault` | 46 MB | Check that Obsidian Sync is really on, or copy it. |
| Codex desktop chats | `~/Documents/Codex` | 47 MB | Copy if you want the history. |
| Notes, pictures | `~/newideas.md`, `~/overlayfeatureidea.md`, `~/Pictures`, `~/reports` | small | Copy. |
| SSH keys | `~/.ssh` (GitHub, Pi, hosthatch, Nikitway deploy) | — | Copy over SSH, or make new keys and authorize them. Never commit. |
| T3 Code threads | `~/.t3/userdata` | 795 MB | Stays on Linux. Threads that must survive a reboot belong on the Pi's T3 server. |
| `onlytuz` local-only work | 5 branches with unpushed commits, 1 stash, uncommitted `src/lib/miva.ts` | — | Push the branches you still want, or leave them on Linux. |
| `OD-Overlay-Website` | staged `site/index.html` on `chore/record-publish-20261105` (no upstream) | — | Commit and push, or drop it. |

Check for unpushed work in any repo:

```bash
for r in ~/Projects/*/ ~/OD-Overlay-Website; do
  [ -e "$r/.git" ] || { echo "NOT GIT  $r"; continue; }
  echo "== $r"
  git -C "$r" status --short | head -5
  git -C "$r" log --branches --not --remotes --oneline | head -5
  git -C "$r" stash list | head -3
done
```

## Moving data

The two systems can't share a disk, so stage files on the Pi.

On Linux (`alarm`), before rebooting:

```bash
ssh pi 'mkdir -p ~/migration && chmod 700 ~/migration'
rsync -a --exclude node_modules --exclude dist --exclude .astro \
  ~/Projects/Nikitway ~/Projects/onlydrafts-website-handoff \
  ~/ObsidianVault ~/Documents/Codex ~/Pictures ~/reports \
  ~/newideas.md ~/overlayfeatureidea.md  pi:migration/
rsync -a ~/.ssh/ pi:migration/ssh/      # only if you copy keys
```

On macOS, after Tailscale is up:

```bash
rsync -a pi:migration/ ~/migration/
# move each item to its place, then:
ssh pi 'rm -rf ~/migration'             # don't leave keys on the Pi
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_*
```

## Setup checklist

Do these in order. Steps 4 to 7 are the same as [`new-machine.md`](new-machine.md).

**No CLI proxy on the Mac.** The hub is paused. Skip every `-hub` step: no
`~/.claude-hub`, no `~/.codex-hub`, no bearer token. Claude and Codex sign in
natively everywhere on the Mac.

### 1. macOS basics

- Update macOS. Sign in with your Apple ID.
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
brew install git gh mise bash python jq ripgrep rust
brew install --cask tailscale
```

- `bash`: macOS ships bash 3.2; `tlnstack` needs bash 4 or newer.
- `rust`: the T3 Code fork's macOS build needs it.
- Activate mise in `~/.zshrc` (`eval "$(mise activate zsh)"`) and add
  `~/.local/bin` to `PATH`.
- Copy `~/.config/mise/config.toml` from `alarm` (`claude`, `codex`, `node`,
  `opencode` at `latest`), then `mise install`.

### 3. Tailscale

Open Tailscale and sign in. Re-authorize `macbook-air-nikita`. Check that
`ssh pi` works.

### 4. GitHub and tlnstack

```bash
gh auth login                          # SSH protocol, like alarm
mkdir -p ~/Projects && cd ~/Projects
gh repo clone NikitaTLN/tlnstack
cd tlnstack && ./scripts/bootstrap.sh
```

The bootstrap links the instructions and skills (symlinks, same as Linux).

### 5. Native sign-in for the CLIs

```bash
claude        # sign in with Claude Max, then /exit
codex login   # sign in with ChatGPT Pro
```

The desktop apps and the CLIs share `~/.claude` and `~/.codex`, so this is
one sign-in each. No hub configs on this machine.

### 6. Desktop apps (native sign-in)

| App | Get it | Sign in | Reads |
| --- | --- | --- | --- |
| Claude | claude.ai/download | Claude Max | `~/.claude/CLAUDE.md`, `~/.claude/skills` |
| Codex | the Codex app for macOS (OpenAI) | ChatGPT Pro | `~/.codex/AGENTS.md`, `~/.codex/skills` |

tlnstack has already linked the instructions and skills into both. Set
Claude's default model to Opus in its settings, not Fable, which needs extra
usage credits.

Both apps can call each other through the `ask-codex` and `ask-claude` skills.
See [`claude-codex.md`](claude-codex.md).

### 7. T3 Code (TLN2Code fork, macOS build)

```bash
cd ~/Projects && gh repo clone NikitaTLN/TLN2Code t3code
cd t3code && git checkout personal
node scripts/personal-fork.mjs configure    # if PR #1 is merged; else set remotes by hand
curl -fsSL https://vite.plus | bash         # installs vp (it brings its own Node)
vp i --frozen-lockfile
vp run dist:desktop:dmg:arm64
```

- The build is unsigned by default. That is fine for your own Mac. In-app
  browser passkeys only work in a signed build (`--signed`, which needs a
  Developer ID and `T3CODE_APPLE_TEAM_ID`).
- Open the `.dmg` and drag T3 Code to Applications. If macOS says it is
  damaged, run `xattr -cr "/Applications/T3 Code.app"`.
- In T3 Code's provider settings, enable the native **Claude**
  (`claudeAgent`) and **Codex** (`codex`) instances. Don't add hub instances.
- Link the Pi as an environment in T3 Code for threads that must survive a
  reboot into Linux.
- For each nightly, follow [`updating.md`](updating.md) §4, but build with
  `dist:desktop:dmg:arm64` in place of the AppImage step. The Linux-only
  variables (`T3CODE_DESKTOP_GLIBC_CEILING`, `TMPDIR`) are not needed on macOS.

### 8. Projects

```bash
cd ~/Projects
gh repo clone 9kantawis/onlytuz
gh repo clone NikitaTLN/voxtype-flow
gh repo clone NikitaTLN/Textio
cd ~ && gh repo clone NikitaTLN/OD-Overlay-Website
```

Recreate worktrees only for branches you are working on (`git-workflow`
skill). `onlytuz` releases are still Windows builds on `w1dget`.

### 9. Verify

```bash
tlnstack --check && tstack-sync --check      # all current
claude --version && codex --version
```

Then run the bridge check in [`claude-codex.md`](claude-codex.md#verify).

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
