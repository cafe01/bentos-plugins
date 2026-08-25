# Proof — bentos-plugins v0.1

Captured 2026-08-25 on Claude Code 2.1.245. Every claim below is the raw output of a command that was actually run.

## Manifest validates

```
$ claude plugin validate /Users/cafe/workspace/bentos/workshop/bentos-agent-plugin
Validating marketplace manifest: .../.claude-plugin/marketplace.json

✔ Validation passed
```

## The agent resolves when the bundle is loaded

```
$ claude -p --plugin-dir plugins/bentos-agent --model sonnet \
    "List the exact names of every plugin-provided agent available to you."
Only one plugin-provided agent is available: bentos-agent.
```

The species resolves under its namespaced name, `bentos-agent:bentos-agent` — the namespace is the plugin name, not the marketplace name.

## The catalog resolves a subdirectory source

The repository is a marketplace whose one entry points at `./plugins/bentos-agent`. `validate` follows that path rather than merely accepting the string: run against a probe with a deliberately author-less nested manifest, it reported `plugins[0] plugin.json → author: No author information provided`, which it could only know by reading the nested file.

```
$ claude plugin validate .
Validating marketplace manifest: .../.claude-plugin/marketplace.json

✔ Validation passed
```

## Contents

| Item | State |
|---|---|
| `plugins/bentos-agent/agents/bentos-agent.md` | 1407 words of the species mind script. No placeholder text. |
| `plugins/bentos-agent/skills/bentos-agent/SKILL.md` | 350 words. Loads in all three target runtimes unmodified. |
| `plugins/bentos-agent/.mcp.json` | Four servers declared: `mem`, `place`, `ask`, `spawn`. No secret, token or key in the repository. |
| `.claude-plugin/marketplace.json` (catalog) + `plugins/bentos-agent/.claude-plugin/plugin.json` | Serves Claude Code and Grok CLI. |
| `.agents/plugins/marketplace.json` (catalog) + `plugins/bentos-agent/.codex-plugin/plugin.json` | Serves Codex CLI. |

## End-to-end install from GitHub

The stranger's path, run against the published repository and then removed again:

```
$ claude plugin marketplace add cafe01/bentos-plugins
✔ Successfully added marketplace: bentos-plugins (declared in user settings)

$ claude plugin install bentos-agent@bentos-plugins
✔ Successfully installed plugin: bentos-agent@bentos-plugins (scope: user)

$ claude plugin details bentos-agent
BentOS Agent (bentos-agent) 0.1.0
Component inventory
  Skills (1)  bentos-agent
  Agents (1)  bentos-agent
  Hooks (0)
  MCP servers (4)  mem, place, ask, spawn
Projected token cost
  Always-on:   ~238 tok   added to every session
```

The four organs register from a clean install. Always-on cost is ~238 tokens per session; the agent body costs ~2.6k only when invoked.

## Not proven here

Install and load on **Grok CLI** and **Codex CLI** are derived from the runtime studies in `lab/agent-plugin/runtimes/`, not re-run against this bundle. Grok reads Claude Code's manifest format verbatim, which is observed in that study but not yet observed against this repository. That is the first thing v0.2 must close.

No hooks ship in v0.1, by decision: hooks did not fire on Grok in testing and need a separate user trust step on Codex.
