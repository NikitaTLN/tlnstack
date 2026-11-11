# Git, branches, worktrees, PRs, releases

The full, authoritative version is the `git-workflow` skill in this repo
(`skills/git-workflow/SKILL.md`), which follows the `onlytuz` conventions. This
page is the summary and the rules that hold on every project.

## Rules that never change

- Never commit to `main` or another default branch. Use a task branch.
- One topic per branch. One branch per worktree. `git worktree list` is the only
  source of truth for which branch lives where.
- The main checkout stays on `main`; leave its uncommitted work alone and never
  stash it.
- Task worktrees live next to the repo:
  `<repo-parent>/<repo-name>-worktrees/<branch>`, keeping the slash.
- Never `git add -A`. Stage named paths or hunks.
- Never plain `--force`. An authorized rewrite uses
  `--force-with-lease=<branch>:<sha>` after a `backup/<branch>-<date>` ref.
- Never `reset --hard` to make the status look clean, and never `rm -rf` a
  worktree.
- A branch can be checked out in only one worktree. Work where it already is.

## Branch names (onlytuz)

| Branch | For | PR base |
| --- | --- | --- |
| `overlay/<name>` | One overlay | `main`, or its shared parent when stacked |
| `shared/<name>` | Shared code, units, i18n, telemetry, CI, infra | `main` |
| `feat/`, `fix/`, `chore/` | Non-overlay work, docs, tooling | `main` |
| `shared/release-X.Y.Z` | A release, cut from updated `main` | `main` |
| `integration/<name>` | Local trial merges only | never a PR head |

Stacking: shared part on `shared/<x>`, overlay branches on it, overlay PRs base
`shared/<x>`. Merge overlays into `shared/<x>`, then `shared/<x>` into `main`.

## Worktree

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

Run `npm ci` in a new worktree; dependencies and build output are per worktree.

## The pipeline

1. **Before editing** — record the worktree, branch, upstream, base, and any
   pre-existing changes.
2. **Sync** — `git fetch origin`, compare ahead/behind, `pull --ff-only` on a
   clean tree, merge `origin/main` (or the shared parent) into the branch.
3. **Check the job is done** — see `docs/workflow.md`.
4. **Commit** — review the whole diff, `git diff --check`, run the checks, stage
   named paths, `type(scope): summary`.
5. **Push** — `git push -u origin HEAD`; confirm the remote SHA matches.
6. **PR** — reuse an existing PR, check the base, read the diff, file it with
   the `file-pr` skill, then `link_pull_request`.
7. **Wait** — `watch_pull_request` (T3) or `gh pr checks <n> --watch`. Fix real
   findings and push again.
8. **Merge** — recheck requirements, then
   `gh pr merge <n> --merge --match-head-commit <sha>`. Keep the branch.
9. **After** — verify the merge is on `main`, `pull --ff-only` the main checkout
   if clean, `unwatch_pull_request`.

## Releases

- Version by size of change since the last tag: **Z** fixes/polish, **Y** new
  features or visible behavior, **X** major or breaking (resets Y and Z).
- Cut `shared/release-X.Y.Z` from updated `origin/main`, bump every version
  file, add the `CHANGELOG.md` section, open the PR, state the version and why.
- Merge only with explicit approval. Merging publishes a live Windows build.
  Afterwards check the Actions run, the website manifest, and the GitHub
  release, and arrange a Windows test.
- Ordinary feature PRs never publish a release.

## This repo (`tlnstack`)

The one exception: `tlnstack` is a personal config repo, like dotfiles. It
tracks `main` directly. Edit; on Linux the installed files are symlinks, so the
change is live, but run `tlnstack sync` to record state, then commit and push.

## Report

| Item | State |
| --- | --- |
| Worktree / branch | path, `branch` -> base |
| Done check | requirements done / total |
| Commits | short SHA and subject |
| Checks | local and CI |
| Push | remote SHA matches local: yes/no |
| PR | full URL, open/merged |
| Merge | merge commit SHA, on `main`: yes/no |
| Left alone | pre-existing changes and skipped steps |
