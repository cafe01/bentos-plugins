# bentos-plugins

The installable vessel for the BentOS agent species: one git repository that carries the `bentos-agent` persona and its four organs — `mem`, `place`, `ask`, `spawn` — into whatever agent harness you already run.

The layout follows Claude Code's plugin format, which the other two supported runtimes already read natively or near-natively:

| Payload | Claude Code | Grok CLI | Codex CLI |
|---|---|---|---|
| `plugins/bentos-agent/skills/bentos-agent/SKILL.md` | yes | yes | yes |
| `plugins/bentos-agent/.mcp.json` (organs) | yes | yes | yes |
| `plugins/bentos-agent/agents/bentos-agent.md` | yes | yes | no — use the skill instead |

Only the manifests differ per runtime (`.claude-plugin/`, `.codex-plugin/` + `.agents/plugins/`); the payload content is identical everywhere.

## This repository is a marketplace, not a plugin

A **plugin** is the unit you install. A **marketplace** is a catalog that lists plugins and says where each one lives. Both are declared in a `.claude-plugin/` directory, which is why they are easy to confuse.

This repository is the catalog. It ships one plugin today and has room for more.

```
bentos-plugins/
├── .claude-plugin/marketplace.json    the catalog
├── .agents/plugins/marketplace.json   the same catalog, for Codex
└── plugins/
    └── bentos-agent/                  a plugin
        ├── .claude-plugin/plugin.json
        ├── .codex-plugin/plugin.json
        ├── agents/  skills/  .mcp.json
```

So you add the marketplace once, then install plugins from it by name.

## Install — Claude Code

```
claude plugin marketplace add cafe01/bentos-plugins
claude plugin install bentos-agent@bentos-plugins
```

Or, for a one-off session without installing:

```
claude --plugin-dir /path/to/bentos-plugins/plugins/bentos-agent
```

Then invoke the persona with `@bentos-agent` or dispatch it via the `Task` tool as `bentos-agent:bentos-agent`. The skill loads automatically and is model-invoked, or run `/bentos-agent:bentos-agent`.

## Install — Grok CLI

Grok reads `.claude-plugin/marketplace.json` unmodified, so the same commands work:

```
grok plugin marketplace add cafe01/bentos-plugins
grok plugin install bentos-agent@bentos-plugins --trust
```

`grok plugin install` is user-scoped (no `--scope` flag); for a project-local install, vendor the repo by hand into `<project>/.grok/plugins/bentos-agent/` instead.

## Install — Codex CLI

Codex has no custom-subagent format, so the `bentos-agent` skill carries the whole persona (skills fold agent + command into one payload there).

```
codex plugin marketplace add cafe01/bentos-plugins
codex plugin add bentos-agent@bentos-plugins
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

Hooks and slash commands are deliberately not shipped in v0.1 — hooks are unproven on Grok and gated behind a trust step on Codex, and commands have no Codex equivalent. The skill and the MCP organs are the floor that loads unmodified everywhere; `plugins/bentos-agent/agents/bentos-agent.md` is the richer face for the two runtimes that read it.

See `PROOF.md` for the validation and load evidence this bundle was checked against before shipping.
