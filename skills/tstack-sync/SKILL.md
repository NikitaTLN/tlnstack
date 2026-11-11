---
name: tstack-sync
description: Update the t3dotgg/tstack skills in Claude Code and Codex. Use when the user says "update tstack", "sync skills", or "check for skill updates".
---

# tstack-sync

Keeps the installed tstack skills in `~/.claude/skills` and `~/.codex/skills`
in step with `t3dotgg/tstack`. The script is `~/.local/share/tstack-sync/sync.sh`.

## Steps

1. Run the check first, so nothing is written:
   `~/.local/share/tstack-sync/sync.sh --check`
2. Show the user the result as a short table: skill, target, action.
   - `install`: a new skill, will be copied.
   - `update`: upstream changed and the local copy was untouched, will be replaced.
   - `current`: already matches upstream.
   - `local-edit`: the local copy was changed by the user. It is never overwritten.
3. If the user asked to update, run `~/.local/share/tstack-sync/sync.sh` without `--check`.
   Report the upstream commit range it printed.

## Local edits

Theo's README says to edit these skills and keep personal settings in
`CLAUDE.md` or `AGENTS.md`. Do not overwrite a `local-edit` skill without asking.
If the user wants the upstream version, show `diff -r` between the local copy
and `~/.local/share/tstack/skills/<name>` first, then ask before deleting the
local copy.

## Notes

- Upstream removals are not deleted from the skill folders. Mention them if the
  clone no longer has a skill that is installed.
- The clone is at `~/.local/share/tstack`. Do not edit it. Edits there are reset
  by the next `git pull`.
