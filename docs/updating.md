# Updating the stack

How to bring every tool on `alarm` and the Raspberry Pi to its newest version,
and the traps found along the way. The Windows PC (`w1dget`) and `omarchy-1`
are updated only when they are online.

## What runs where

| Tool | `alarm` | Raspberry Pi |
| --- | --- | --- |
| Claude Code | mise (`~/.config/mise/config.toml`, `latest`) | native installer (`~/.local/share/claude/versions`) |
| Codex | mise | standalone (`~/.codex/packages/standalone`) |
| Hub configs | `~/.claude-hub`, `~/.codex-hub`, `~/.codex-openai-api` (Codex API) | `~/.claude-hub`, `~/.codex-hub` |
| T3 Code | **TLN2Code** fork, built locally as an AppImage | **upstream** T3 Code nightly, as a `t3` background service |
| tlnstack / tstack | `~/Projects/tlnstack`, `~/.local/share/tstack` | same paths (installed 2026-11-18) |

The hub configs and the Codex API config use the **same binaries** as the
native ones; only the config folder differs. Updating `claude` and `codex`
updates every instance. Check one with `CLAUDE_CONFIG_DIR=~/.claude-hub claude
--version` or `CODEX_HOME=~/.codex-hub codex --version`.

## 1. Find the newest versions

```bash
npm view @anthropic-ai/claude-code dist-tags.latest
npm view @openai/codex dist-tags.latest
gh release list -R pingdotgg/t3code -L 3        # newest "T3 Code Nightly"
```

Use npm or GitHub as the source of truth. On 2026-11-18, `mise latest` showed an
older version than npm, so never trust `mise upgrade` alone.

## 2. Claude Code and Codex

`alarm` (mise; pass the exact versions):

```bash
mise install claude@<version> codex@<version>
claude --version; codex --version
mise prune -y          # removes the old versions (each is 300-500 MB)
```

The wrappers in `~/.local/bin/claude` and `~/.local/bin/codex` call `mise x`,
so they follow `latest` automatically.

Raspberry Pi:

```bash
ssh raspberrypi
claude update
codex update
```

## 3. Codex models: the Hub catalog

Codex Hub does not ask OpenAI for models. It reads a fixed catalog
(`model_catalog_json = "~/.codex-hub/model-catalog.json"`), so **new models do
not appear until the catalog is rebuilt**. When OpenAI ships a model, run on
each machine:

```bash
codex debug models > /dev/null      # refresh native Codex's model list
codex-hub-catalog --check           # compare
codex-hub-catalog                   # rewrite, keeps a .bak-<date>
```

The script keeps only models the CLI proxy serves (it asks the proxy's
`/v1/models`). If a new model is missing from the proxy, update CLIProxyAPI on the
Pi first (`~/cliproxyapi`, `systemctl --user restart cliproxyapi`).

Verify with a real request on each instance:

```bash
for h in .codex .codex-hub .codex-openai-api; do for m in gpt-6.2-sol gpt-6.2-astra; do
  CODEX_HOME=~/$h codex exec --skip-git-repo-check --sandbox read-only -m $m \
    -c model_reasoning_effort=low "Reply with exactly the word OK" 2>/dev/null | tail -1
done; done
```

Known problem: **Codex API** (`~/.codex-openai-api`) lists every model but
OpenAI rejects every request with `codex_byok_restricted_by_api_credit_promo`.
The organization is enrolled in the monthly API Credits benefit, which blocks
Codex usage. An organization owner must cancel it at
<https://platform.openai.com/settings/organization/billing/overview>. The Pi has
no Codex API instance.

## 4. TLN2Code on `alarm`

The fork follows published upstream nightlies (see `docs/t3code-fork.md`).

1. Merge the nightly in a task worktree, never on `personal`:

   ```bash
   cd ~/Projects/t3code && git fetch --all --tags
   T=v<newest nightly tag>; B=chore/nightly-<date>.<build>
   git worktree add -b $B ../t3code-worktrees/$B personal
   cd ../t3code-worktrees/$B && git merge --no-ff --no-commit $T
   ```

2. Resolve conflicts. They land in the personal features: Voxtype dictation,
   sidebar drafts, the usage ring, send later, starred models, XML preview, and
   sidebar artwork. Upstream moves fast here: as of 0.1.11 dictation lives in
   `apps/web/src/speech/voiceInputSession.ts` (Voxtype is part of its session
   key), and all UI copy must be translated.
3. Check, in this order:

   ```bash
   vp i --frozen-lockfile
   vp run typecheck
   vp lint --report-unused-disable-directives   # no-untranslated-copy: wrap copy in gt()/<T>/msg()
   (cd apps/web && vp run i18n:generate); (cd apps/mobile && vp run i18n:generate)
   vp run i18n:check
   (cd apps/web && vp test run src/speech src/components/sidebar)   # plus what the conflicts touched
   (cd apps/server && vp test run src/speech)
   ```

4. Commit the merge, push, and open a PR into `personal` (`file-pr` skill).
5. Build the arm64 AppImage. **Both variables are required on `alarm`:**

   ```bash
   mkdir -p ~/.cache/t3-desktop-build-tmp
   TMPDIR=$HOME/.cache/t3-desktop-build-tmp T3CODE_DESKTOP_GLIBC_CEILING=2.42 \
     vp run dist:desktop:artifact --platform linux --target AppImage --arch arm64 \
     --output-dir ~/Projects/t3code/release/<name>
   ```

   - `T3CODE_DESKTOP_GLIBC_CEILING`: Arch's glibc (2.42) is newer than the
     release ceiling (2.39), so `node-pty` fails the glibc check without it.
   - `TMPDIR`: `/tmp` is a 3.7 GB tmpfs; the `.deb` step runs out of space
     there and `ar` fails.
   - The build needs about 1.5 GB of free disk space.

6. Install. The `t3-code` launcher starts the newest `T3-Code-*-arm64.AppImage`
   by modification time:

   ```bash
   cp ~/Projects/t3code/release/<name>/T3-Code-<ver>-arm64.AppImage ~/.local/share/t3-code/appimages/
   ~/.local/bin/t3-code --launcher-path          # must print the new file
   sed -i 's#T3-Code-<old>-arm64#T3-Code-<ver>-arm64#' ~/.local/share/applications/com.t3tools.T3Code.desktop
   ```

   Then quit and reopen T3 Code. An agent running inside T3 Code cannot do this
   for you, because it would end its own session.

7. Clean up: keep the previous AppImage for rollback and delete older ones.
   Delete `release/<name>`, because the installed copy is enough.

The old sidebar-artwork patcher
(`~/.local/share/t3-code/sidebar-artwork/prepare.py.disabled`) is disabled. The
fork has the fix built in, so the patcher no longer matches and only wasted a
500 MB extraction on every launch.

## 5. T3 Code on the Raspberry Pi (upstream)

The Pi runs upstream T3 Code, not the fork, to keep maintenance low.

```bash
ssh raspberrypi
t3 update --channel nightly --yes     # restarts the t3code service
t3 --version; systemctl --user is-active t3code.service
```

The restart briefly interrupts anything running on the Pi's server.

## 6. tlnstack and tstack

On each machine:

```bash
cd ~/Projects/tlnstack && git pull --ff-only && tlnstack --check && tlnstack
tstack-sync --check && tstack-sync
```

Both `--check` runs must report only `current`.

## 7. Disk space on `alarm`

The root partition is 79 GB and fills up. After an update:

```bash
mise prune -y
mise cache clear; npm cache clean --force; rm -rf ~/.cache/pnpm
(cd ~/Projects/t3code && pnpm store prune)
ls ~/.local/share/t3-code/appimages ~/Projects/t3code/release
```

Large items to keep: `~/.cache/electron*` (the build needs it) and the
`*-worktrees` folders (active work).

## Checklist

| Item | `alarm` | Pi |
| --- | --- | --- |
| Claude Code = npm latest | `claude --version` | `claude --version` |
| Codex = npm latest | `codex --version` | `codex --version` |
| Hub lists the newest models | `codex-hub-catalog --check` | `codex-hub-catalog --check` |
| New models answer | smoke test above | smoke test above |
| T3 Code | TLN2Code PR open, AppImage installed, app restarted | `t3 --version` = newest nightly |
| tlnstack / tstack | both `--check` clean | both `--check` clean |
