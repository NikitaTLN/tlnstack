# Credentials and the T3 Code secret store

Agents never ask for a secret in chat and never invent one. The rule, in order:

1. T3 Code secret store (`request_secret`)
2. 1Password provider (a reference instead of a value)
3. The harness's own secret/keyring facility, or `op read`
4. A chat ask, only when nothing else exists, one secret at a time

This applies to API keys, tokens, webhook signing secrets, device host tokens,
and login passwords, including the **`sudo` password** on a machine that is not
passwordless.

## 1. T3 Code secret store

An agent that needs a secret calls the `request_secret` tool. T3 Code shows a
private card in the thread. The user types or pastes the value and selects
**Save securely** (or **Decline**). The value never appears in the conversation
and never returns to the agent as plain text.

Input:

| Field | Required | Meaning |
| --- | --- | --- |
| `label` | yes | Card title, such as `GitHub webhook secret`. |
| `reason` | yes | What it is for and where the user gets it. |
| `placeholder` | no | Hint inside the input. |
| `delivery` | no | `secretRef` (default) or `file`. |
| `value` | no | Use only when the user already pasted it; skips the card. |
| `timeoutMs` | no | How long to wait. Default 10 minutes, max 1 hour. |
| `clientRequestId` | no | Reuse to retry a call whose result was lost. New id to ask again. |

Result:

| Status | Meaning |
| --- | --- |
| `saved` + `secretRef` | A one-use reference. Pass it to a T3 tool that accepts one. The agent never sees the value. |
| `saved` + `file` | `delivery: "file"`: an owner-only file holds the value. Read it inside commands, never print it. Deleted after about 24 hours. |
| `declined` | The user chose not to. Do not ask again. |
| `cancelled` | The request ended with the run. |
| `timed_out` | No answer in time. Re-ask with a new `clientRequestId` only if still needed. |

### When a command needs the value (including `sudo`)

Use `delivery: "file"`. T3 Code writes the value to a private file and returns
its path. Read it only inside the command:

```bash
# password in "$file" from request_secret with delivery "file"
sudo -S true < "$file"          # verify, discard output
sudo -S -- apt-get update < "$file"
```

Never `cat` the file, never put its path in the transcript, and treat it as gone
after 24 hours. On a headless machine with no card UI reachable, fall through to
the next option.

### 1Password provider

T3 Code can read credentials from 1Password through the `op` CLI, so only a
reference is stored. Set it up in **Settings → Secrets → Add provider** on the
machine that runs the T3 Code server. Credential fields then accept
`op://vault/item/field`.

- On a headless or remote server (the Raspberry Pi), sign `op` in with a
  **service account** (`OP_SERVICE_ACCOUNT_TOKEN`) or a **1Password Connect**
  server (`OP_CONNECT_HOST` / `OP_CONNECT_TOKEN`). A desktop sign-in asks for
  approval on the server's machine, which a remote user cannot answer.
- When the card offers it, pick the provider and enter the reference instead of
  typing the value.

Docs: `docs/user/secrets.md`, `secrets-1password-service-account.md`, and
`secrets-1password-connect.md` in `pingdotgg/t3code`.

## 3. Fallback outside T3 Code

- Claude Code / Codex outside T3: use the harness's own secret handling if it
  has one; otherwise use the OS keyring.
- 1Password CLI, signed in: `op read "op://vault/item/field"` inside the command
  that needs it. Do not echo the result.
- `gh`, `npm`, `cargo`, and `git` credentials live in their own stores. Prefer
  those over passing a token by hand.

## 4. Chat ask, last resort

Only when the store, a provider, and the harness have nothing. Ask for one
secret, say exactly what it is for, use it once, never echo it, and never write
it into a committed file.

## Never

- Put a secret in the transcript, a commit, a PR body, a report, or a log.
- Commit `publish.token`, hub bearer tokens, `~/.codex/auth.json`,
  `~/.t3/userdata/secrets/`, or any `*.env` with real values.
- Invent, guess, or reuse a placeholder secret.
- Print the `file` from a `delivery: "file"` request.
