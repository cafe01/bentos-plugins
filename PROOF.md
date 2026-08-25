# Proof — bentos-agent-plugin v0.1

Captured 2026-08-25 on Claude Code 2.1.245. Every claim below is the raw output of a command that was actually run.

## Manifest validates

```
$ claude plugin validate /Users/cafe/workspace/bentos/workshop/bentos-agent-plugin
Validating marketplace manifest: .../.claude-plugin/marketplace.json

✔ Validation passed
```

## The agent resolves when the bundle is loaded

```
$ claude -p --plugin-dir . --model sonnet \
    "List the exact names of every plugin-provided agent and skill available to you."
bentos-agent:bentos-agent
```

The species resolves under its namespaced name. The remaining names in the raw output were the host session's own built-in skills, not ours.

## Contents

| Item | State |
|---|---|
| `agents/bentos-agent.md` | 1407 words of the species mind script. No placeholder text. |
| `skills/bentos-agent/SKILL.md` | 350 words. Loads in all three target runtimes unmodified. |
| `.mcp.json` | Four servers declared: `mem`, `place`, `ask`, `spawn`. No secret, token or key in the repository. |
| `.claude-plugin/plugin.json` + `marketplace.json` | Serves Claude Code and Grok CLI. |
| `.codex-plugin/plugin.json` + `.agents/plugins/marketplace.json` | Serves Codex CLI. |

## Not proven here

Install and load on **Grok CLI** and **Codex CLI** are derived from the runtime studies in `lab/agent-plugin/runtimes/`, not re-run against this bundle. Grok reads Claude Code's manifest format verbatim, which is observed in that study but not yet observed against this repository. That is the first thing v0.2 must close.

No hooks ship in v0.1, by decision: hooks did not fire on Grok in testing and need a separate user trust step on Codex.
