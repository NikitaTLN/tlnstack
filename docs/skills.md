# Skills

Three sources, all installed into the same skill folders.

## Personal (this repo)

Installed by `tlnstack sync` into every skill folder.

| Skill | Say | What it does |
| --- | --- | --- |
| `git-workflow` | "git workflow", "ship it" | Full branch, worktree, commit, push, PR, merge, release flow, with the done-check. |
| `redo` | "redo" | Redo, refactor, or redesign a PR or the current work. |
| `browser-report` | "browser report" | A styled standalone HTML report in `~/reports`, opened in the browser. |
| `tstack-sync` | "update tstack" | Checks and applies upstream `t3dotgg/tstack` updates. |
| `tlnstack-sync` | "update tlnstack", "sync my stack" | Checks and applies this repo's files and skills. |

## t3dotgg/tstack (third-party)

Theo's skills, cloned to `~/.local/share/tstack` and installed by `tstack-sync`.

`full-send`, `full-stop`, `council`, `sol-loop`, `file-pr`, `babysit-pr`,
`takeover`, `modernize`, `leaving-pr-comments`.

Personal settings for these (council members, PR style) live in
`agents/AGENTS.md`, so the skills can be updated without losing them.

## Matt Pocock library (third-party)

27 engineering skills at `~/.local/share/mattpocock-skills/skills`
(`engineering/` and `productivity/`). Not picker entries; read the `SKILL.md`
on demand. `engineering/ask-matt/SKILL.md` routes by situation. The installed
`AGENTS.md` describes the triggers.

## Claude plugin skills

Synced by the Claude plugin system into `~/.claude/skills/synced`: `apple-design`,
`built-in-browser`, `chrome-browser`, `computer-use`, `deep-research`, `docs`,
`docx`, `google-workspace`, `import-memory`, `morning`, `odessa-surzhyk`, `pdf`,
`pptx`, `skill-creator`, `xlsx`. Managed by the plugin marketplace, not by
tlnstack.

## Omarchy skills

`diagnose-crash` and `omarchy` are symlinks into
`~/.local/share/omarchy/default/agents/skills`. Installed with Omarchy, not by
tlnstack.

## Updating

```bash
tlnstack sync        # this repo -> every machine's files and skills
tlnstack --check     # show what would change
tstack-sync.sh --check   # check the third-party tstack skills
```

See `docs/new-machine.md` for installing all three sources on a fresh machine.
