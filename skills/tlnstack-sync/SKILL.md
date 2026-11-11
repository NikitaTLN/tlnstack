---
name: tlnstack-sync
description: Update the tlnstack instructions and personal skills on this machine from the NikitaTLN/tlnstack repo. Use when the user says "update tlnstack", "sync tlnstack", "sync my stack", or "set up this machine".
---

# tlnstack-sync

Keeps the global instructions (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, the
hub copies, `~/.config/opencode/AGENTS.md`) and the personal skills in step with
`NikitaTLN/tlnstack`. The CLI is `tlnstack`
(`~/Projects/tlnstack/scripts/tlnstack`).

## Steps

1. Update the clone:

   ```bash
   cd ~/Projects/tlnstack && git pull --ff-only
   ```

   If the repo is missing, clone it: `gh repo clone NikitaTLN/tlnstack ~/Projects/tlnstack`.

2. Check first, so nothing is written:

   ```bash
   tlnstack --check
   ```

3. Show the user the result as a short table: target, action.
   - `install`: not present yet, will be linked (Linux) or copied (Windows).
   - `adopt`: present but never managed by tlnstack. Taken over on the first
     run, with a backup.
   - `update`: the repo changed and the installed copy was untouched (copy mode).
   - `convert`: a copy is being replaced by a link, or vice versa.
   - `relink`: a link pointed at the wrong place.
   - `current`: already matches the repo.
   - `local-edit`: the installed copy was changed by hand. It is never
     overwritten unless the user asks for `--force`.

4. If the user asked to update, run `tlnstack` (no `--check`) and report what
   changed. Add `--force` only when the user wants to overwrite a `local-edit`.

## Capturing a local edit

If the user changed an installed file by hand and wants to keep it, run
`tlnstack --capture`. It copies the installed version back into the repo
(`agents/AGENTS.md` or `skills/<name>/`), refusing when targets disagree. On a
linked machine there is nothing to capture: edits land in the repo directly.
Then review `git diff`, commit on `main`, and push.

## Notes

- The repo is `~/Projects/tlnstack`. It tracks `main` directly; there are no
  task branches.
- On Linux, `tlnstack` links each target to the repo, so an edit in the repo
  is live and other machines pick it up with `git pull` alone. On Windows,
  copies are used, so run `tlnstack sync` after a change.
- To change the shared setup for every machine, edit the repo, not an installed
  copy, then commit and push.
- Third-party skills are separate: say **"update tstack"** for Theo's skills.
  The Matt Pocock library is cloned once by `scripts/bootstrap.sh`.
