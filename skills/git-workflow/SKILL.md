---
name: git-workflow
description: The user's full Git workflow for branches, worktrees, commits, pushes, PRs, merges, and releases, including a check that every requested feature is actually done before merging. Use when the user mentions this skill or asks to commit, push, open a PR, merge, ship, or "do the git stuff", or when starting work that needs a branch or worktree.
---

# Git workflow

Mentioning this skill means: do the Git work yourself, end to end, without
asking for each step. The user should not have to say "commit, push, open a
PR, merge" again.

The repository's own `AGENTS.md` (and `CLAUDE.md`) wins wherever it differs
from this file. Read it in the worktree you work in. This skill comes from the
`onlytuz` / OnlyDrafts project and follows its conventions by default.

## What a mention authorizes

| User says | Do |
| --- | --- |
| just the skill, "ship it", "commit push pr merge" | Branch, check the job is done (and finish what's missing), commit, push, open or update the PR, wait for checks, merge |
| "no merge", "just a PR", "up to PR" | Everything up to an open PR with green checks. Do not merge |
| "just commit", "local only" | Commit on the task branch. Do not push |
| "set up a branch/worktree" | Prepare the worktree and stop before editing |

Limits that still need an explicit, same-request "yes":

- **Release PRs** (`shared/release-X.Y.Z`). Merging one publishes a live
  Windows build to the website and GitHub. Open it, but merge only when the user
  says to merge the release.
- Rewriting published history (rebasing a pushed branch, `--force-with-lease`).
- Deleting branches or worktrees.
- Anything that touches someone else's uncommitted work.

If a step is blocked (failing CI you cannot fix, review changes requested,
conflicts that need a product decision), stop there and report the blocker. Do
not work around it.

## Branches

Never commit to `main` or any other default branch. If `main` is checked out,
use or create a task worktree before editing.

| Branch | For | PR base |
| --- | --- | --- |
| `overlay/<name>` | One overlay: `overlay/pitlane`, `overlay/input` | `main`, or its shared parent when stacked |
| `shared/<name>` | Code several overlays use: units, localization, telemetry, CI, infra | `main` |
| `feat/<name>`, `chore/<name>`, `fix/<name>` | Work that is neither overlay- nor shared-specific, docs, tooling | `main` |
| `shared/release-X.Y.Z` | A release, cut from updated `main` | `main` |
| `integration/<name>` | Local trial merges of several branches. Never a PR head | none |

- One overlay per branch. Do not mix independent overlay changes. Follow-ups
  for an overlay stay on its branch.
- **Stacking:** when overlay work needs a shared change, put the shared part on
  `shared/<x>`, build the overlay branches on it, and open the overlay PRs with
  base `shared/<x>`. When `shared/<x>` moves, merge it into each overlay branch
  (`git merge shared/<x>`). Merge the overlay PRs into `shared/<x>` first, then
  `shared/<x>` into `main`.
- Reuse an existing branch for the same topic instead of making a new one.

## Worktrees

`git worktree list` is the only source of truth for which branch lives where.

- The main checkout (for example `~/Projects/onlytuz`) stays on `main`. Leave
  its uncommitted changes and index alone. Never stash them.
- Task worktrees live next to the repo:
  `<repo-parent>/<repo-name>-worktrees/<branch>`, keeping the slash in the
  branch name. Example: `~/Projects/onlytuz-worktrees/overlay/blindspot`.
- A branch can be checked out in only one worktree. If the branch already has
  one, work there. Do not switch another checkout to it.
- Each worktree has its own files, index, `node_modules`, and build output.
  Run `npm ci` in a new worktree before building.
- Remove a worktree only when asked and only after its work is pushed, with
  `git worktree remove <path>`. Never `rm -rf` it or use `--force`.

Open or create the worktree for a branch:

```bash
repo_root=$(git worktree list --porcelain | sed -n '1s/^worktree //p')
worktree_root="$(dirname "$repo_root")/$(basename "$repo_root")-worktrees"
branch=overlay/blindspot
git -C "$repo_root" fetch origin
git -C "$repo_root" worktree list | grep -F "[$branch]" || {
  if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$repo_root" worktree add "$worktree_root/$branch" "$branch"
  elif git -C "$repo_root" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git -C "$repo_root" worktree add --track -b "$branch" "$worktree_root/$branch" "origin/$branch"
  else
    git -C "$repo_root" worktree add --no-track -b "$branch" "$worktree_root/$branch" origin/main
  fi
}
```

For a stacked branch, create it from `origin/shared/<x>` instead of
`origin/main`.

## The pipeline

Run each step in the task worktree. Use absolute paths or `git -C`.

### 1. Before editing

```bash
pwd; git status --short --branch; git branch -vv
git diff --stat; git diff --cached --stat
```

Note any changes that were already there. They are not yours: do not stage,
revert, or report them as your work.

### 2. Sync

```bash
git fetch origin
git rev-list --left-right --count HEAD...@{upstream}   # ahead / behind
```

- Behind on a clean tree: `git pull --ff-only`.
- Ahead is fine. Diverged: look at both sides and integrate them. Never
  `reset --hard` to the remote to make the status look clean.
- Bring in the base: `git merge origin/main` on pushed branches. Stacked
  branches merge their `shared/<x>` parent instead. Rebase only unpushed
  commits. Before any history rewrite, save a backup ref:
  `git branch backup/<branch>-$(date +%Y%m%d-%H%M) HEAD`.
- Resolve conflicts by reading both sides, then rerun the checks.

### 3. Check the job is done

Long threads lose track of things. The user and the agent can both forget a
feature that was asked for early on. Before you commit for the PR, check the
work against everything that was asked for, not against what you remember.

Unlike `/modernize`, do not ask whether the change should exist. Assume the goal
is wanted and only check that it is complete.

1. **Collect every requirement.** Read each source in full, not from memory:
   - **The thread:** every user message from the start, including any summary
     of earlier context. In T3 Code, if earlier turns were summarized,
     `t3_thread_read` this thread to recover the original asks. Note anything
     the user asked for, agreed to, or said "later" to.
   - **The issue(s):** `gh issue view <n> --json title,body,comments,labels`
     for the issue the branch works on (from the branch name, thread, commits,
     or PR body). Read its expected behavior, acceptance criteria, checklists,
     open questions, comments, and sub-issues.
   - **The PR**, if one exists: body checklists, unresolved review threads,
     and requested changes.
   - **Your own promises:** plans, TODO lists, and "I'll also..." messages
     earlier in the thread. Run `git diff origin/<base>...HEAD | grep -nE 'TODO|FIXME|XXX'`
     for markers you added.
   - **Repo follow-through** the change implies. In onlytuz: English and
     Russian strings with key parity, a `CHANGELOG.md` entry under
     **Unreleased** for user-facing changes, the feature's `docs/*.md` page,
     tests in `tools/*.test.mjs` or Rust, and the registration points for a new
     overlay or setting: overlay stage, OBS, editor rail, enable list,
     inspector, settings, sizing, layout defaults, Rust settings.
2. **Build the checklist.** One row per requirement, checked against the actual
   diff and behavior, not the commit messages:

   | Requirement | Source | Status | Evidence |
   | --- | --- | --- | --- |
   | Right-click a driver row opens the menu | #142 Expected behavior | done | `src/...:120`, preview |
   | Notes persist across restarts | #142 | missing | no storage code |
   | Russian strings | repo rule | done | `i18n-hud.ts` key parity test |

   Status is one of `done`, `partial`, `missing`, `deferred` (the user
   explicitly said to leave it out), or `decision` (an open question nobody
   answered).
3. **Act on the gaps:**
   - `missing` or `partial` and clearly in scope: build it now, in the same
     task. The skill mention covers this. Then rerun the checks and this step.
   - `decision`: if the answer is not in the issue or thread, ask the user. You
     may still open the PR, but do not merge until it's answered.
   - Too big for this PR, or the user deferred it: leave it out and list it
     under **Not in this PR** in the PR body. Use `Part of #N` instead of
     `Closes #N`, so the issue stays open. Offer to file a follow-up issue.
   - `done` everywhere: continue.
4. Put the checklist in the PR body (or a collapsed `<details>` block) and in
   the final report, so the user can spot a missing item at a glance.

### 4. Commit

1. Review the whole diff and run `git diff --check`.
2. Run the checks that fit the change. In onlytuz: `npm run build`, and
   `node --test tools/*.test.mjs` when logic changed. CI runs `npm ci` and
   `npm run build` on every PR into `main`.
3. Stage named paths only: `git add -- <paths>` or `git add -p`. Never
   `git add -A` or `git add .`. Build output such as `src-tauri/target-win/`
   and secrets such as `publish.token` must stay out.
4. Check what is staged: `git diff --cached --stat`, `git diff --cached`,
   `git diff --cached --check`.
5. Commit with a Conventional Commit message: `type(scope): summary`.
   - Types: `feat`, `fix`, `perf`, `docs`, `refactor`, `test`, `chore`, `ci`.
     Add `!` for breaking changes.
   - Scope is the overlay or area: `feat(tiretemps): ...`, `ci(release): ...`.
   - The summary says what the user gets, in plain words.
   - End with the harness's attribution trailer if it gives one.
6. Verify: `git show --stat --oneline HEAD` and `git status --short --branch`.

Make small, logical commits. Split unrelated changes into separate commits, or
separate branches if they are separate topics.

### 5. Push

```bash
git fetch origin
git push -u origin HEAD          # first push of a new branch
git push                         # later pushes
git rev-parse HEAD origin/$(git branch --show-current)   # must match
```

Never use plain `--force`. If an authorized rewrite needs a force push, use
`--force-with-lease=<branch>:<expected-remote-sha>`.

### 6. Pull request

1. Look for an existing PR first: `gh pr list --head <branch> --state all`.
   Update that one instead of opening a second.
2. Check the base: `main`, or `shared/<x>` for a stacked overlay.
3. Read the PR diff against its base: `gh pr diff <n>` or
   `git diff origin/<base>...HEAD`. It must hold only this task's changes.
4. Title in the same `type(scope): summary` form, saying why it matters.
5. Body follows `.github/pull_request_template.md`:
   - **Summary:** open with the problem, then the fix. No file-by-file list.
   - `Closes #N` only when step 3 found every item of the issue done.
     Otherwise `Part of #N`, plus a **Not in this PR** list.
   - The step 3 checklist.
   - **Testing:** checks run, preview URL, and what still needs a Windows or
     iRacing test, as unchecked boxes.
   - Checklist: branch naming and base, `npm run build`, English and Russian
     strings.
   - End with the model and harness attribution line.
6. Open a real PR, not a draft. If GraphQL is rate limited, use
   `gh api repos/<owner>/<repo>/pulls -f title=... -f head=... -f base=... -F body=@<file>`.
7. In T3 Code, call `link_pull_request` with the full URL right away, for
   every PR in a stack.
8. When pushing again later, update the title and body to match the final
   change.

### 7. Wait for checks and reviews

- In T3 Code: `watch_pull_request`, then end the turn. Continue when it wakes
  you. Do not sleep, poll, or use `gh pr checks --watch`.
- Elsewhere: `gh pr checks <n> --watch`.
- Failing checks on your change: fix them, commit, push, wait again.
- Review comments: address them, or reply with the reason when you disagree.
  AI review is a second opinion, not a substitute for your own review.

### 8. Merge

Rerun step 3 quickly first. Reviews, new issue comments, or your own fixes may
have added or dropped requirements since the PR opened. Do not merge while any
item is `missing`, `partial`, or `decision`.

Right before merging, check the PR again:

```bash
gh pr view <n> --json state,baseRefName,headRefOid,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup
```

Then merge with a merge commit, pinned to the head you checked:

```bash
gh pr merge <n> --merge --match-head-commit <headRefOid>
```

- The repo uses merge commits ("Merge pull request #N from ..."). Do not squash
  or rebase unless asked.
- Keep the branch: no `--delete-branch`. Branches and worktrees stay unless the
  user asks to clean up.
- For a stack, merge the overlay PRs into `shared/<x>`, then the shared PR into
  `main`.

### 9. After merge

```bash
gh pr view <n> --json state,mergeCommit
git fetch origin
git merge-base --is-ancestor <merge-commit> origin/main && echo "on main"
```

- Fast-forward the main checkout with `git -C <repo_root> pull --ff-only`, but
  only if it has no uncommitted changes. Otherwise leave it and say so.
- In T3 Code, `unwatch_pull_request` before handing back.
- Finish with `git status --short --branch` in the task worktree.

## Releases

1. Choose the version from what changed since the last release tag, not by
   always bumping Z:
   - **Z**: fixes, polish, small tweaks.
   - **Y**: new features, overlays, or settings, or behavior users will notice.
     Resets Z.
   - **X**: big overhaul, or changes to saved settings or compatibility.
     Resets Y and Z.
   Ask the user when it's unclear whether the release is a Y or an X.
2. Cut `shared/release-X.Y.Z` from updated `origin/main`. Bump every version
   file and add the `## X.Y.Z` section to `CHANGELOG.md` as `docs/PUBLISHING.md`
   describes.
3. Open the release PR into `main`. State the version and why it was chosen.
4. Merge only with explicit approval. Merging publishes live. Afterwards, check
   the Actions run, the website manifest, and the GitHub release `vX.Y.Z`, and
   arrange a Windows test.

Ordinary feature PRs never publish a release.

## Subagents

Subagents follow the same rules. Give each independent branch its own
worktree. Agents sharing a worktree stay on its assigned branch. When a
subagent hands work back, rerun steps 1, 3 and 4 before you push.

## Never

- Commit on `main`, or stash or reset the main checkout's local changes.
- `git add -A`, plain `--force`, `reset --hard` to clean up, or `rm -rf` a
  worktree.
- Say something is pushed, opened, merged, or clean without checking that
  exact state.
- Merge, or write `Closes #N`, from memory of what was asked. Check the
  thread and the issue.

## Report back

Keep the report short:

| Item | State |
| --- | --- |
| Worktree / branch | path, `branch` -> base |
| Done check | requirements done / total, plus anything built late, deferred, or waiting on a decision |
| Commits | short SHA and subject |
| Checks | local and CI results |
| Push | remote SHA matches local: yes/no |
| PR | full URL, open/merged |
| Merge | merge commit SHA, on `main`: yes/no |
| Left alone | changes that were already there, skipped steps and why |
