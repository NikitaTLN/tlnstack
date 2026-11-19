---
name: browser-report
description: Create a styled HTML report as a file and open it in the browser. Use when the user asks for an HTML report in the browser, a browser report, or a report they can open themselves.
---

# browser-report

Writes one standalone HTML file and opens it in the default browser. Use it for finished results with several items: install summaries, comparisons, status tables, workflows, audits.

Use this skill for a file the user opens in a browser. For a page shown inline in T3 Code, use `html_preview` and `html_render` instead.

## Steps

1. Choose a slug: lowercase, hyphens, short, for example `tstack-install`. Write to `~/reports/<slug>.html`. Run `mkdir -p ~/reports` first. If the file exists and you did not create it in this task, add the date as a suffix instead of overwriting it.
2. Write one self-contained HTML file. No external CSS, fonts, scripts, or images. Use the style block below as the base.
3. Structure, top to bottom:
   - Header: title and a one-line subtitle.
   - Summary card: the answer in one or two sentences.
   - Up to three stat tiles, only for real numbers.
   - Tables for comparisons and status. Use `pill` for states.
   - A `note` block for warnings the user must see.
   - Next steps as numbered steps or a short list.
   - Footer with the date and the source (repo, commit, or files read).
4. Open it: `open ~/reports/<slug>.html` on macOS, `xdg-open ~/reports/<slug>.html >/dev/null 2>&1 &` on Linux
5. Reply with the absolute path as a link and one line on what the report covers. Do not restate the report's contents.

## Style block

```html
<style>
  :root {
    --bg: #fafafa; --card: #ffffff; --fg: #18181b; --muted: #71717a;
    --border: #e4e4e7; --ok: #15803d; --ok-bg: #dcfce7; --warn: #a16207; --warn-bg: #fef9c3;
    --code: #f4f4f5; --radius: 10px;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --bg: #09090b; --card: #18181b; --fg: #fafafa; --muted: #a1a1aa;
      --border: #27272a; --ok: #4ade80; --ok-bg: #14532d; --warn: #facc15; --warn-bg: #422006;
      --code: #27272a;
    }
  }
  * { box-sizing: border-box; }
  body { margin: 0; background: var(--bg); color: var(--fg); font: 15px/1.55 system-ui, -apple-system, "Segoe UI", sans-serif; }
  main { max-width: 860px; margin: 0 auto; padding: 48px 24px 72px; }
  header h1 { font-size: 28px; margin: 0 0 6px; letter-spacing: -0.01em; }
  header p { margin: 0; color: var(--muted); }
  h2 { font-size: 13px; text-transform: uppercase; letter-spacing: .07em; color: var(--muted); margin: 40px 0 12px; padding-bottom: 8px; border-bottom: 1px solid var(--border); }
  .card { background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); padding: 20px; }
  .summary { font-size: 16px; }
  .stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-top: 16px; }
  .stat { background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); padding: 16px; }
  .stat .num { font-size: 26px; font-weight: 700; }
  .stat .label { color: var(--muted); font-size: 13px; }
  table { width: 100%; border-collapse: collapse; background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); overflow: hidden; font-size: 14px; }
  th, td { text-align: left; padding: 10px 14px; border-bottom: 1px solid var(--border); vertical-align: top; }
  tr:last-child td { border-bottom: none; }
  th { color: var(--muted); font-weight: 600; font-size: 13px; }
  code { font-family: ui-monospace, "SFMono-Regular", Menlo, monospace; font-size: 13px; background: var(--code); padding: 2px 6px; border-radius: 5px; }
  .pill { display: inline-block; font-size: 12px; font-weight: 600; padding: 2px 9px; border-radius: 999px; background: var(--ok-bg); color: var(--ok); white-space: nowrap; }
  .pill.warn { background: var(--warn-bg); color: var(--warn); }
  .note { border-left: 3px solid var(--warn); background: var(--warn-bg); padding: 12px 16px; border-radius: 6px; margin: 10px 0; }
  .steps { counter-reset: s; list-style: none; padding: 0; margin: 0; display: grid; gap: 10px; }
  .steps li { counter-increment: s; background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); padding: 14px 16px 14px 56px; position: relative; }
  .steps li::before { content: counter(s); position: absolute; left: 16px; top: 14px; width: 26px; height: 26px; border-radius: 50%; background: var(--code); display: grid; place-items: center; font-weight: 700; font-size: 13px; }
  ul.plain { padding-left: 20px; margin: 0; }
  ul.plain li { margin: 6px 0; }
  footer { margin-top: 48px; color: var(--muted); font-size: 13px; }
  @media (max-width: 640px) { .stats { grid-template-columns: 1fr; } table { font-size: 13px; } }
</style>
```

## Rules

- Keep the text short. Tables and tags carry the detail.
- One file per report. No build step, no server.
- Use plain words for statuses: installed, missing, changed, blocked, done.
- Do not put secrets, tokens, or private hostnames in the report. Redact them.
