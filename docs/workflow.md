# Workflow

How I work, on every machine, with every agent. This is the long version of the
installed `AGENTS.md` / `CLAUDE.md`.

## The loop

```
request / issue
  -> pick branch + worktree        (never main)
  -> implement on the branch
  -> check the job is actually done
  -> verify (build, tests, preview)
  -> commit -> push -> open/update PR -> link it
  -> wait for checks and reviews (watch_pull_request, never poll)
  -> fix real findings, re-verify
  -> merge when authorized -> verify on main
  -> release only when asked
```

## Harnesses and machines

- Agents run through **T3 Code**. Claude Code goes through `~/.claude-hub`,
  Codex through `~/.codex-hub`, both pointing at the CLI proxy on the Raspberry
  Pi. OpenCode runs natively.
- Every harness gets the same global instructions (this repo's
  `agents/AGENTS.md`) and the same skills.
- Machine inventory and paths: `docs/machines.md`.

## Starting work

- Read the repository's own `AGENTS.md` / `CLAUDE.md` first; it wins over this
  file. In `onlytuz`, also read `docs/agents/*`.
- Read the request in full: the thread, the issue, the PR body, and my own
  earlier promises. Do not work from memory.
- Fetch the base before deciding anything is up to date.

## Branches and worktrees

Never commit to `main` in a project repo. One topic per branch, one branch per
worktree. Full rules and the copy-paste commands are in `docs/git.md` and the
`git-workflow` skill.

| Branch | For |
| --- | --- |
| `overlay/<name>` | One overlay in `onlytuz` |
| `shared/<name>` | Code several overlays use; also CI, infra, docs |
| `feat/`, `fix/`, `chore/` | Everything else |
| `shared/release-X.Y.Z` | A release, cut from updated `main` |
| `integration/<name>` | Local trial merges only, never a PR head |

Stacked work: shared part on `shared/<x>`, overlay branches built on it, overlay
PRs target `shared/<x>`; merge overlays into the shared branch first, then the
shared branch into `main`.

## Check the job is done

Before committing for a PR, build a checklist from every requirement and check
it against the diff and the running product, not the commit messages.

| Status | Meaning |
| --- | --- |
| `done` | Present and verified. |
| `partial` / `missing` | Build it now, in the same task. |
| `deferred` | I said to leave it out. List it under **Not in this PR**. |
| `decision` | An open question nobody answered. Ask; do not merge. |

Put the checklist in the PR body and the final report.

## Verify

- Run the checks that fit the change. In `onlytuz`: `npm run build`, and
  `node --test tools/*.test.mjs` when logic changed. CI runs `npm ci` and
  `npm run build` on every PR into `main`.
- Frontend and overlay work: prepare and show a working preview before handing
  back. Agents own dependency install, server start, port choice, and opening
  the preview. Publish it on Tailscale when available. The user's only step is
  viewing it.
- UI changes get a before/after. Numbers get a chart. Use `html_render`.

## Commit, push, PR, merge

- Conventional commits: `type(scope): summary` (`feat`, `fix`, `perf`, `docs`,
  `refactor`, `test`, `chore`, `ci`; `!` for breaking).
- Stage named paths only. Never `git add -A`.
- Push with `git push -u origin HEAD`, never plain `--force`.
- Look for an existing PR first; update it instead of opening a second.
- In T3 Code, `link_pull_request` with the full URL right away, for every layer
  of a stack.
- Wait with `watch_pull_request`, then end the turn. Never sleep or poll.
- Merge with a merge commit pinned to the head you checked
  (`gh pr merge <n> --merge --match-head-commit <sha>`). The repo uses merge
  commits; no squash or rebase unless asked. No `--delete-branch`.
- After merge, verify the merge commit is on `main`, fast-forward the main
  checkout if it is clean, and `unwatch_pull_request`.

Releases: only from `shared/release-X.Y.Z`, only when I say to merge. Choosing
X/Y/Z is by the size of the change, not a reflex. Merging publishes a live build.

## Subagents and delegation

- Use `delegate_task` for another provider's model, user-requested settings, or
  a separate checkout (`isolation: "worktree"`). Use a native subagent when the
  child uses my provider and model with no extra settings.
- Give each independent branch its own worktree. Agents sharing a worktree stay
  on its branch.
- When a subagent hands back, rerun the before-edit check, the done check, and
  the commit check before pushing.
- Every new review or re-check is a new delegate, not a message to the old one.
  Follow a running delegate's `next`; never poll it.

## T3 Code features to reach for

`html_preview` / `html_render`, `delegate_task`, `watch_pull_request`,
`link_pull_request`, `request_secret`, `preview_*`, `create_threads` /
`t3_thread_launch`, `schedule_task`. Details in `docs/t3-code.md`.

## Credentials

T3 Code's secret store first, then 1Password, then the harness, then a chat ask.
Details in `docs/credentials.md`.

## Skills

Personal skills live in this repo and install with `tlnstack sync`. Third-party
skills come from `t3dotgg/tstack` and the Matt Pocock library. Inventory and
provenance: `docs/skills.md`.
