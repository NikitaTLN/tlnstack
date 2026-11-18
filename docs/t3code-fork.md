# Personal T3 Code fork

Repository: https://github.com/NikitaTLN/TLN2Code

The local checkout is `~/Projects/t3code`. `personal` is the integration/default
branch and follows **published nightly releases** of `pingdotgg/t3code`.
`origin` points to Nikita's fork, `upstream` to the original repo; upstream
pushes are disabled locally. `main` is an upstream reference, not a task base.

Use the usual workflow with `personal` in place of `main`: task branches and
sibling worktrees at `~/Projects/t3code-worktrees/<branch>`, Conventional
Commits, real PRs in Nikita's fork, focused checks and merge commits. The
primary checkout stays on `personal`; do not develop or commit directly there.
Use the repository's Vite+ tooling rather than the generic `npm ci` examples.

The versioned setup/runbook lives in the fork at
`docs/operations/personal-fork.md`. It includes another-machine setup and these
cross-platform commands:

```sh
node scripts/personal-fork.mjs configure
node scripts/personal-fork.mjs worktree fix/example
node scripts/personal-fork.mjs nightly
node scripts/personal-fork.mjs sync
```

As of 2026-11-18 `scripts/personal-fork.mjs` and the runbook exist only on the
unmerged `chore/fork-bootstrap` branch (PR #1), not on `personal`. Until it is
merged, update by hand: see the TLN2Code section of
[`updating.md`](updating.md), which also has the arm64 AppImage build and
install steps.

Nightly sync prepares an update worktree for review; it does not deploy,
publish, or overwrite local changes. Stable and preview releases are excluded.
The initial fork uses manual artifact installs. Provider credentials, local
T3 data, signing credentials, and native/hub configuration remain machine-local.
No installed production T3 service is replaced by setting up the source repo.
