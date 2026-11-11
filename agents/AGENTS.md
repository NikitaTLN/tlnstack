# Default setup

- Default to the CLI proxy hub. Claude Code runs through `~/.claude-hub` and
  Codex runs through `~/.codex-hub`. Both point at the CLI proxy on the
  Raspberry Pi. Look for config, instructions, and skills there first.
- `~/.claude` and `~/.codex` mirror the hub folders. Keep them the same.
- OpenCode runs natively; its global instructions live in
  `~/.config/opencode/AGENTS.md`.
- This file is installed by **tlnstack** (`~/Projects/tlnstack`). Edit it in the
  repo, then run `tlnstack sync`, and commit and push the change. Do not edit an
  installed copy directly.

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
2. **1Password provider.** If the environment has a 1Password provider
   configured, the card also lets the user pick a reference such as
   `op://vault/item/field` instead of typing the value.
3. **Harness secret mechanism.** Outside T3 Code, use the harness's own secret
   or keyring facility. Prefer `op read` when 1Password is signed in.
4. **Chat ask (last resort).** Only when nothing above exists. Ask for one
   secret at a time, use it once, never echo it, and never write it to a file
   that is committed.

Never commit secrets. `publish.token`, hub bearer tokens, `auth.json`, and
`secrets/` stay out of every repo. If a secret is exposed, say so and rotate it.

Full guide: `~/Projects/tlnstack/docs/credentials.md`.

# Git and branches

- Never commit to `main` in a project repo. Work on a task branch or worktree.
- In `onlytuz`, follow the repository's own `AGENTS.md` and the `git-workflow`
  skill. Branch, worktree, commit, push, PR, and release rules are there.
- This personal config repo (`tlnstack`) is the exception: it tracks `main`
  directly, like a dotfiles repo.
- Full workflow: `~/Projects/tlnstack/docs/git.md` and
  `~/Projects/tlnstack/docs/workflow.md`.

# Pull requests

- File a real PR, not a draft.
- Title: concise, says why the change matters.
- Description: lead with the problem, then the fix. Don't start with a list of
  file changes.
- Check the change against the diff before filing.

# Council (personal settings for the tstack `council` skill)

Plans: Claude Pro ($20) and ChatGPT Plus ($20). Both have tight 5-hour limits,
so council is built to spend little.

- Members: two, on purpose. Claude Opus 5.5 on Claude Hub (`claudeAgent_2`,
  effort `high`) and GPT-6.1 Sol on Codex Hub (`codex_2`, reasoningEffort
  `high`). Don't report the missing third provider, and don't add a second model
  from the same provider.
- Don't use Fable for council. It drains a Pro plan too fast.
- Run council only when I ask for it, not for every change.
- Round 1: both members review in parallel. Give them the diff, the goal, and
  the checks that ran. Ask for findings tagged `important`, `nit`, or
  `pre-existing`, and a score out of 10. Don't tell them the passing score.
- Pass: 8/10 or better and no open `important` finding. Ignore nits unless they
  are cheap to fix.
- Later rounds: ask only the members who did not pass, and send only the new
  diff. Don't repeat findings already fixed or closed.
- Stop after 3 rounds. Report what is still open and suggest a different
  approach instead of another round.
- If a member hits a usage limit, stop that member, write `usage limit` in its
  score cell, and finish with the other. Don't swap in another model.

<!-- mattpocock-skills-library -->
## Matt Pocock skill library

A library of 27 engineering skills lives at `/home/w1dget/.local/share/mattpocock-skills/skills/`
(`engineering/` and `productivity/`). They are not listed as picker
entries, so use them on demand: when a task matches one, read its
`SKILL.md` and follow it.

Triggers: TDD / test-first work, code review, diagnosing a bug, domain modeling,
glossary or ADR work, codebase/interface design, grilling or stress-testing a
plan, research, throwaway prototypes, writing a PR body, specs and tickets,
triage, handoff, teaching, and writing docs for agents.

`ls /home/w1dget/.local/share/mattpocock-skills/skills/*/` for the full list.
`engineering/ask-matt/SKILL.md` routes by situation.
<!-- /mattpocock-skills-library -->
