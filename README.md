# bentos-agent-plugin

The installable vessel for the BentOS agent species: one git repository that carries the `bentos-agent` persona and its four organs — `mem`, `place`, `ask`, `spawn` — into whatever agent harness you already run.

The layout follows Claude Code's plugin format, which the other two supported runtimes already read natively or near-natively:

| Payload | Claude Code | Grok CLI | Codex CLI |
|---|---|---|---|
| `skills/bentos-agent/SKILL.md` | yes | yes | yes |
| `.mcp.json` (organs) | yes | yes | yes |
| `agents/bentos-agent.md` | yes | yes | no — use the skill instead |

Only the manifests differ per runtime (`.claude-plugin/`, `.codex-plugin/` + `.agents/plugins/`); the payload content is identical everywhere.

## Install — Claude Code

```
claude plugin marketplace add <this-repo-url-or-path>
claude plugin install bentos-agent@bentos-agent-plugin
```

Or, for a one-off session without installing:

```
claude --plugin-dir /path/to/bentos-agent-plugin
```

Then invoke the persona with `@bentos-agent` or dispatch it via the `Task` tool as `bentos-agent-plugin:bentos-agent`. The skill loads automatically and is model-invoked, or run `/bentos-agent-plugin:bentos-agent`.

## Install — Grok CLI

Grok reads `.claude-plugin/marketplace.json` unmodified, so the same commands work:

```
grok plugin marketplace add <this-repo-url-or-path>
grok plugin install bentos-agent@bentos-agent-plugin --trust
```

`grok plugin install` is user-scoped (no `--scope` flag); for a project-local install, vendor the repo by hand into `<project>/.grok/plugins/bentos-agent/` instead.

## Install — Codex CLI

Codex has no custom-subagent format, so the `bentos-agent` skill carries the whole persona (skills fold agent + command into one payload there).

```
codex plugin marketplace add <this-repo-url-or-path>
codex plugin add bentos-agent@bentos-agent-plugin
```

Invoke the skill explicitly with `$bentos-agent`, or let the model select it implicitly. MCP servers register automatically on install (`codex mcp list` to confirm).

## Organs

`.mcp.json` declares four MCP servers, all launched through the shared `mcp` CLI (must be on `PATH`):

- `mem` — the memory organ
- `place` — the organ of WHERE
- `ask` — the voice organ, for questions to the human
- `spawn` — the runtime organ, for waking peer threads

Each organ's own `--help` is its manual; the agent and skill bodies only state the being-level conduct around them.

## What's not here

Hooks and slash commands are deliberately not shipped in v0.1 — hooks are unproven on Grok and gated behind a trust step on Codex, and commands have no Codex equivalent. The skill and the MCP organs are the floor that loads unmodified everywhere; `agents/bentos-agent.md` is the richer face for the two runtimes that read it.

See `PROOF.md` for the validation and load evidence this bundle was checked against before shipping.
