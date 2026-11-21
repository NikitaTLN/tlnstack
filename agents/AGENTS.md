# Default setup

- `~/.claude` and `~/.codex` are the **native** configs, signed in to Claude
  (Max) and ChatGPT (Pro) directly. This is the default everywhere.
- The **CLI proxy is paused** (as of 2026-11-19). It runs on the Raspberry Pi,
  port 8317, and its configs carry a `-hub` suffix: `~/.claude-hub` and
  `~/.codex-hub`. Don't set it up on a new machine, including the Mac. Only
  `alarm` still has the hub folders. Where they exist, they hold the same
  instructions and skills, and a harness running through the proxy reads them
  first.
- OpenCode runs natively; its global instructions live in
  `~/.config/opencode/AGENTS.md`.
- I work in three places: **T3 Code**, the **Claude desktop app**, and the
  **Codex desktop app**. All of them use the native configs on the Mac. On
  `alarm`, T3 Code and the CLIs may still use the `-hub` configs.
- My main machine is a MacBook Air M2. It dual-boots **macOS** (main, needed
  for Xcode and iOS work) and Arch Linux (Asahi, host `alarm`). See
  `~/Projects/tlnstack/docs/macos.md`.
- This file is installed by **tlnstack** (`~/Projects/tlnstack`). On Linux and
  macOS it is symlinked to the repo, so an edit in the repo is live; run
  `tlnstack sync` anyway to record state, then commit and push. On Windows it is
  a copy, so `tlnstack sync` is required. Do not edit an installed copy
  directly.

# Working style

## Reports after a finished task

- Open with the answer in one or two sentences.
- If the result has more than a few items, end with a visual report, not a wall
  of text. In T3 Code: write the HTML, check it with `html_preview`, then show it
  with `html_render`. Outside T3 Code, use a short markdown summary with
  headings and a table.
- Report structure: short answer, status table (item, source, status), what
  changed, how it was verified, decisions I made for you, next steps.
- Use tables for comparisons and status, short tags (yes/no, done/blocked) for
  states, and short sentences. No long paragraphs.
- Don't announce the rendered page or repeat it in the reply. Say only what the
  page doesn't already show.

## Use T3 Code features by default

- Diagrams of flows, architecture, or state: `html_render` with a self-contained
  page.
- Numbers or comparisons: a chart in `html_render`. Use the dataviz skill for
  chart colors.
- UI changes: a mockup or before/after page in `html_render`.
- Subagents on another provider's model: `delegate_task`, not a native subagent.
- Waiting on a PR: `watch_pull_request`, not a sleep or polling loop.
- Credentials: `request_secret`, not a chat ask. See below.

# Browsers

My browser is **Helium**. It has my sign-ins, extensions, and open tabs.

- **Default: Helium through computer use.** Websites and online services
  (GitHub, dashboards, accounts, consoles, docs, stores) go through Helium,
  driven with computer use (screenshots, clicks, typing). This is most cases.
- **Built-in browser only for a local server.** The harness's own in-app
  browser pane is for an app running locally: a dev server or preview of the
  project at `localhost`, `127.0.0.1`, or a `*.localhost` / `*.test` host.
- When unsure which one, use Helium.
- Reading a public page for facts needs no browser: a web fetch or search tool
  is fine.
- If computer use is not available (on `alarm`, or in a harness without it),
  say so and ask before falling back to the built-in browser.
- Sign-ins, passwords, 2FA, and CAPTCHAs in Helium stay mine.

# Claude and Codex together

Claude and Codex can call each other from any app. Use this when I ask for a
second opinion, a cross-review, or a hand-off ("ask codex", "ask claude",
"both of you look at this").

- From Claude: the `ask-codex` skill. From Codex: the `ask-claude` skill. Both
  run the other CLI headless in the same repo and bring its answer back.
- In T3 Code, use `delegate_task` to the other provider instead, so the child
  shows up in T3 Code.
- The child matches the caller's config: native by default; a hub session on
  `alarm` calls the hub.
- A bridged child gets `TLN_BRIDGE=1` and never calls back. One hop only.
- The child works read-only unless I ask it to write code. Then it works in its
  own worktree, and the caller reviews its diff before committing.
- Report which model said what, and give your own view. Don't apply the other
  model's advice unchecked.
- Not on every change. Only when I ask, or for council.

Full guide: `~/Projects/tlnstack/docs/claude-codex.md`.

# Credentials

Never ask for a token, password, API key, or secret in chat, and never invent
one. Get it from T3 Code's secure credential store first.

1. **T3 Code secret store (preferred).** Call the `request_secret` tool. The
   user answers in a private card; the value never enters the transcript.
   - `label` and `reason`: say what it is and where to get it.
   - `delivery: "secretRef"` (default) when a T3 tool consumes it. The result
     carries a one-use `secretRef`; pass it to the tool that needs it.
   - `delivery: "file"` when a **command** needs the value, including a `sudo`
     password or a login a CLI expects. The result carries `file`: an owner-only
     file your commands can read. Read it inside the command
     (`sudo -S ... < "$file"`), never print it, and know it is deleted after
     about 24 hours.
   - `value` only when the user already pasted it and no card is wanted.
   - Handle `declined`, `cancelled`, and `timed_out`; re-ask with a new
     `clientRequestId` only when still needed.
2. **Harness secret mechanism.** Outside T3 Code, use the harness's own secret
   or keyring facility.
3. **Chat ask (last resort).** Only when nothing above exists. Ask for one
   secret at a time, use it once, never echo it, and never write it to a file
   that is committed.

Never commit secrets. `publish.token`, hub bearer tokens, `auth.json`, and
`secrets/` stay out of every repo. If a secret is exposed, say so and rotate it.

Full guide: `~/Projects/tlnstack/docs/credentials.md`.

# Git and branches

- Never commit to `main` in a project repo. Work on a task branch or worktree.
- Read the repository's own `AGENTS.md` / `CLAUDE.md` first when it exists; it
  wins over this file.
- The `git-workflow` skill has the branch, worktree, commit, push, PR, and
  release rules.
- This personal config repo (`tlnstack`) is the exception: it tracks `main`
  directly, like a dotfiles repo.
- Full workflow: `~/Projects/tlnstack/docs/git.md` and
  `~/Projects/tlnstack/docs/workflow.md`.

# Pull requests

- File every PR with the `file-pr` skill. It has the title and description
  conventions.
- File a real PR, not a draft, so review bots run.
- Check the change against the diff before filing.

# Council (personal settings for the tstack `council` skill)

Plans: Claude Max ($100) and ChatGPT Pro ($100). Both have about 5x the usage
of the $20 plans. Council uses the strongest models on both, so run it only
when I ask, not for every change.

- Members: four, two per provider, all at effort `high`. This replaces the
  skill's "one model from each of three providers". Don't report a missing
  third provider.

  | Member | Instance | Model id |
  | --- | --- | --- |
  | Claude Opus 5.5 | `claudeAgent` | `claude-opus-5-5` |
  | Claude Fable 5.2 | `claudeAgent` | `claude-fable-5-2` |
  | GPT-6.2 Sol | `codex` | `gpt-6.2-sol` |
  | GPT-6.2 Astra | `codex` | `gpt-6.2-astra` |

  If the native instance is disabled (on `alarm`), use the hub one
  (`claudeAgent_2`, `codex_2`).
- Fable draws extra usage credits on Max. That is accepted for council. When
  the credits run out, treat it as a usage limit (below).
- Round 1: all four review in parallel. Give them the diff, the goal, and the
  checks that ran. Ask for findings tagged `important`, `nit`, or
  `pre-existing`, and a score out of 10. Don't tell them the passing score.
- Member passes: 8/10 or better and none of its `important` findings open. A
  finding is closed when it is fixed, or when I checked it, found it wrong,
  and said why in the report. Ignore nits unless they are cheap to fix.
- Council passes when every member has passed. A member that passed doesn't
  review again.
- Later rounds: ask only the members who did not pass, and send only the new
  diff. Don't repeat findings already fixed or closed.
- Stop after 3 rounds. Report what is still open and suggest a different
  approach instead of another round.
- If a member hits a usage limit, stop that member, write `usage limit` in its
  score cell, and finish with the others. Don't swap in another model.

<!-- mattpocock-skills-library -->
## Matt Pocock skill library

A library of 27 engineering skills lives at `~/.local/share/mattpocock-skills/skills/`
(`engineering/` and `productivity/`). They are not listed as picker
entries, so use them on demand: when a task matches one, read its
`SKILL.md` and follow it.

Triggers: TDD / test-first work, code review, diagnosing a bug, domain modeling,
glossary or ADR work, codebase/interface design, grilling or stress-testing a
plan, research, throwaway prototypes, writing a PR body, specs and tickets,
triage, handoff, teaching, and writing docs for agents.

`ls ~/.local/share/mattpocock-skills/skills/*/` for the full list.
`engineering/ask-matt/SKILL.md` routes by situation.
<!-- /mattpocock-skills-library -->
