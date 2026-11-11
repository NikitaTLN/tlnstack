---
name: redo
description: >-
  Redo work the user did not like, on an open PR, the current branch, or the
  changes just made in this thread. Use when the user mentions this skill or
  says "redo", "rework", "refactor this", "redesign", "do it again", "do it
  differently", or that they don't like what an agent built, its code, or its
  design.
---

# Redo

The user looked at the work and did not like it. Do it again, properly, in the
same place.

This is `modernize` without the verdict. Do not ask whether the change should
exist, and do not answer with MODERNIZE, REWORK, or CLOSE. The user already
decided: the goal stays, the attempt goes. Never talk them out of it or
defend the old code because it is already written.

The repository's `AGENTS.md` / `CLAUDE.md` wins where it differs from this
file. Use `git-workflow` for branch, worktree, commit, and push mechanics.
To run it unattended to the end, mention `full-stop` or `full-send` with it
(see "Combining").

## What to redo

| The user gives | Target |
| --- | --- |
| A PR number or URL | That PR, in its branch's worktree |
| Nothing, on a task branch with an open PR | The current branch's PR |
| Nothing, and the work has no PR yet | What this thread built: the branch diff against its base, plus uncommitted changes |
| Several PRs, or "all open PRs" | Each one separately, in its own worktree. Never mix them |

- A merged PR cannot be redone in place. Cut a new branch from the updated base
  and open a follow-up PR.
- A closed, unmerged PR: ask before reopening it.
- Someone else's PR that you may not push to: use `takeover` instead.

## What kind of redo

| Kind | The user says | What changes | What must not change |
| --- | --- | --- | --- |
| Redo | "do it again", "this is wrong", "it doesn't work" | The approach and the code | The goal and every requirement |
| Refactor | "refactor", "messy", "too complicated", "hacky" | The code's structure | Behavior, UI, saved data, public names |
| Redesign | "I don't like the design", "ugly", "looks off" | Look, layout, interaction | The features and data behind it |

More than one can apply. Whatever the user said they dislike is the brief: fix
that first, and everything it implies.

If they gave no reason, find it yourself. Read the diff as a strict reviewer
who did not write it, and use the product the way a user would. Pick the few
real problems (five at most), name them in a line each, and fix them. Do not
ask "what didn't you like?". Ask one question only when two readings would
lead to opposite work.

## Steps

### 1. Read the attempt

Read it in full, not from memory:

- **PR:** title, body, linked issues, commits, review threads, checks, and the
  complete diff against its base.
- **Thread:** every user message from the start. In T3 Code, if earlier turns
  were summarized, `t3_thread_read` the thread to recover them.
- **Running product:** for UI, open it and take a "before" screenshot.

Write down four things before changing anything:

1. The goal, in one sentence.
2. The requirements: everything the work must do, from the issue, the thread,
   and the repo's own rules (strings, docs, tests, changelog).
3. What the attempt does today, including the parts that were fine.
4. The complaints: the user's, then your own.

### 2. Get into the right worktree

`git worktree list` says where the branch lives. Work there. Changes that were
already in the tree and are not part of this task belong to the user: do not
stage, revert, or rewrite them.

### 3. Save a way back

```bash
# committed work
git branch backup/<branch>-$(date +%Y%m%d-%H%M) HEAD

# uncommitted work: snapshot without touching the tree
snap=$(git stash create) && [ -n "$snap" ] && \
  git update-ref refs/backup/redo-$(date +%Y%m%d-%H%M) "$snap"
```

`git stash create` skips untracked files. Copy any new file you are about to
delete or replace to a scratch folder outside the repo first.

### 4. Bring in the base

`git fetch origin`, then merge the PR's real base into the branch
(`git merge origin/<base>`). Do not rebase a pushed branch, except under
`full-stop` / `full-send` (see "Combining").

Look at what landed on the base since the branch started. Use the helpers and
patterns that now exist, and drop anything the base already does. If the base
already solves the whole goal, say so in one line of the report and still
deliver what was asked.

### 5. Choose how deep to go

- **Patch:** the approach is right and parts of it are wrong. Fix those parts.
- **Rewrite:** the approach is the problem. Write the new version from the
  requirements, not by editing the old code line by line. Then remove the old
  version completely.

Take the smallest one that truly fixes the complaints. Do not keep code just
because it exists. Do not rewrite what was fine.

### 6. Build it

- Every requirement from step 1 still works, unless the user said to drop it.
- Follow how the repo already does the same kind of thing. Reuse before
  adding.
- Leave one way to do each thing. Delete replaced code, dead flags, unused
  strings, and leftover files.
- No scope growth. A new idea goes into the report as a suggestion.
- **Refactor:** behavior stays identical. Existing tests pass unchanged. If a
  test must change, say why.
- **Redesign:** match the product's existing components, spacing, colors, and
  type before inventing anything. Check small and large sizes, empty and full
  states, light and dark, and every language the product ships. With no
  direction from the user, build the version you would pick. Offer
  alternatives as mockups only when asked for options.

### 7. Verify against step 1

- Run the repo's checks for the touched area (build, tests, lint).
- Go through the requirement list and the "what it does today" list, one row
  at a time, against the real diff and the running product.
- Check each complaint is actually gone, not moved.
- UI: take an "after" screenshot and compare it with "before". In T3 Code,
  show the before/after with `html_preview` and `html_render`.
- Read the final diff against the base once more. It must hold only this
  task.

### 8. Put it back where it was

- **Open PR:** add new commits to the same branch and push normally. Never
  open a second PR for the same work. Never force-push; rewrite history only
  if the user asks for a clean history or mentions `full-stop` / `full-send`,
  and then with `--force-with-lease=<branch>:<sha>` after the backup from
  step 3.
- Rewrite the PR title and body so they describe the final result, not the
  history of attempts. Keep `Closes #N` / `Part of #N` correct.
- **No PR and nothing was committed:** leave the result uncommitted too,
  unless the user asked for the Git steps or mentioned `git-workflow`,
  `full-stop`, or `full-send`.
- Other branches stacked on this one: name them in the report. Update them
  only when asked.
- Do not post PR comments unless asked. Use `leaving-pr-comments` when you do.

### 9. Stop before merging

The user rejected the first attempt, so they look at the second one. Wait for
checks, then hand back. Merge only if the same request says to, or
`git-workflow` or `full-send` was mentioned with it. `full-stop` never merges.

## Combining

`redo` decides **what** to change. A skill mentioned with it decides **how
far** to take it. Run redo steps 1 to 7 first, then hand over to the other
skill's workflow.

| Mentioned with | After the redo | Merge |
| --- | --- | --- |
| nothing | Push to the same PR, wait for checks, hand back | no |
| `full-stop` | Its proof, `sol-loop` review, `file-pr` (updates the existing PR), `babysit-pr`, merge gate | no, ends ready to merge |
| `full-send` | Same as `full-stop` | yes, when the gate passes |
| `git-workflow` | Its done check, commit, push, PR, checks | yes, unless "no merge" |

When `full-stop` or `full-send` is in the request:

- **Base and history:** they allow a rebase and `--force-with-lease`. Follow
  the repo's `AGENTS.md` first. If it allows both, rebase, but only after the
  backup from step 3, and lease against the remote head you recorded.
- **Proof:** the step 1 requirement list and complaint list are part of the
  proof. The merge gate also needs every complaint fixed and every requirement
  kept, shown in the diff or the running product.
- **Questions:** the user is not watching. Do not stop to ask what they
  disliked; find it yourself. If two readings lead to opposite work, ask with
  the harness's question tool, not in a normal message.
- **PR body:** add one line on what the first attempt got wrong and what the
  redo changed, next to the proof line.

## Never

- Judge whether the PR should exist, or recommend closing it.
- Drop a requirement quietly to make the redo simpler.
- Leave the old and the new implementation side by side.
- Discard the old attempt without the backup from step 3.
- Say a complaint is fixed without checking it in the diff or the product.

## Report

Open with one sentence: what was wrong and what it is now. Then:

| Item | State |
| --- | --- |
| Target | PR URL or branch, worktree path |
| Kind / depth | redo, refactor, or redesign; patch or rewrite |
| Complaints | each one: fixed / not fixed, with evidence |
| Requirements | kept / total, and anything dropped on the user's word |
| Checks | local and CI results |
| Way back | backup branch or ref name |
| Left alone | pre-existing changes, stacked branches, skipped steps and why |

Add the before/after for UI work, and suggestions you did not build. Say what
you could not verify.
