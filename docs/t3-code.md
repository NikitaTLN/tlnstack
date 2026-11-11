# T3 Code features used by default

T3 Code is the control surface for the agents. When its tools are available,
prefer them over a shell workaround.

## Showing results

- `html_preview` then `html_render`: diagrams of flows, architecture, or state;
  charts for numbers; before/after for UI changes. One self-contained page. Do
  not start a server.
- Use the dataviz skill for chart colors.
- A file the user opens themselves (not inline): the `browser-report` skill,
  which writes `~/reports/<slug>.html` and opens it.

## Delegation

- `orchestrator_capabilities` once per thread before the first `delegate_task`,
  to resolve provider/model ids.
- `delegate_task` for another provider's model, user-requested settings, or a
  separate checkout (`isolation: "worktree"`).
- Native subagents only when the child uses my provider and model with no extra
  settings. Background agents always use `delegate_task`.
- Every new review or re-check is a new delegate. Follow a running delegate's
  `next`; never poll it.

## Threads

- `create_threads` / `t3_thread_launch` only when I ask for new or separate
  top-level threads. Not for "subagent" or "delegate".
- `t3_thread_read` before answering about a thread. Mention a thread by its
  `link`, verbatim.

## Pull requests

- `link_pull_request` right after creating or taking over a PR, every layer of a
  stack. Then `watch_pull_request` and end the turn.
- Never sleep, poll, `gh --watch`, or loop while waiting.

## Secrets

- `request_secret` for any token, password, or API key. `delivery: "secretRef"`
  for a T3 tool, `delivery: "file"` for a command (including `sudo`). Full guide:
  `docs/credentials.md`.

## Machines and previews

- `t3_environment_links` lists linked machines; pass the `environmentId` to act
  there.
- `preview_*` tools drive the in-app preview for frontend work. `preview_status`
  first, then `preview_open` / `preview_navigate` with
  `target: {kind: "environment-port", port: <n>}`.

## Scheduling

- `schedule_task` when I ask for a recurring task. When I ask only to schedule,
  do not run the prompt.

## Secrets in the environment

- Provider credentials live in `~/.claude-hub/settings.json`,
  `~/.codex-hub/config.toml`, and `~/.t3/userdata/secrets/`. These are never
  committed. The hub bearer token is one value; get it from the Pi or the
  credential store, not from this repo.
