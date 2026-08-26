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

## End-to-end install on Grok CLI

Grok reads this repository's Claude-format catalog and manifest with no changes of its own — observed against the published repository, not derived.

```
$ grok plugin marketplace add cafe01/bentos-plugins
Added marketplace source: bentos-plugins (https://github.com/cafe01/bentos-plugins.git)

$ grok plugin install bentos-agent@bentos-plugins --trust
Installed 1 plugin(s) from bentos-plugins: bentos-agent

$ grok plugin details bentos-agent
  plugins (1): bentos-agent v0.1.0
  components: 1 skill dir(s), 0 command dir(s), 1 agent dir(s), MCP servers
```

The agent resolves at runtime as `bentos-agent:bentos-agent` and the skill as `bentos-agent`. All four organs connect:

```
$ grok -p "List every MCP server attached to this session..."
ask
mem
place
spawn

None failed to connect. The MCP registry status is `ready`.
```

## End-to-end install on Codex CLI

Observed against the published repository, in a scratch `CODEX_HOME`:

```
$ codex plugin marketplace add cafe01/bentos-plugins
{ "marketplaceName": "bentos-plugins", "alreadyAdded": false }

$ codex plugin list --available
"available": [ { "pluginId": "bentos-agent@bentos-plugins", "version": "0.1.0" } ]

$ codex plugin add bentos-agent@bentos-plugins
{ "pluginId": "bentos-agent@bentos-plugins", "version": "0.1.0",
  "installedPath": ".../plugins/cache/bentos-plugins/bentos-agent/0.1.0" }
```

Codex resolves the catalog entry's relative `path` into an absolute path inside its own clone of the marketplace. All three target runtimes install this bundle from GitHub.

> [!note] An earlier version of this file claimed Codex did not work.
> That claim was published in commits `a7cce5c` and `fb92966` and was false. It was drawn from intermediate output files left in the lab by another session's arm, read as if they were a finished result — and one of those files recorded an error caused by a directory rename I made underneath that arm while it ran. The peer session that owned the arm caught it and said so. Corrected 2026-08-25.

## The turn stamp ships, and it fires

The line that stood here said no hooks ship. That was true of v0.1 and false from commit `1116c0a`, which added `hooks/turn-context.sh`. Corrected 2026-08-26.

One `UserPromptSubmit` hook ships. It fires on Claude Code; it did not fire on Grok in testing, and Codex gates it behind a separate user trust step — so the stamp is a Claude-Code fact and never the bundle's floor.

Observed on Claude Code 2.1.246, in a thread started from inside an agent session where no person was present:

```
$ claude -p 'Quote verbatim any <turn .../> tag present in your context.'
<turn at="2026-08-26T17:10:34-03:00" from="cafe" kind="human" />
```

The environment the hook read belonged to the ancestor thread, not to this one: a frozen `BENTOS_PEER` re-served as if it described the running turn. The hook now compares `BENTOS_THREAD` against the session id the harness supplies on its stdin, and stamps `kind="unknown"` when they differ.

The harness does supply it — captured from a hook that dumped its own stdin:

```
{"session_id":"62d70279-ae29-4950-b857-5153968f7824","transcript_path":"...",
 "cwd":"...","hook_event_name":"UserPromptSubmit","prompt":"say ok"}
```

Same command, same session, seven minutes later, after the fix was pushed and reinstalled through `claude plugin update`:

```
$ claude -p 'Quote verbatim any <turn .../> tag present in your context.'
<turn at="2026-08-26T17:17:08-03:00" kind="unknown" />
```

And a live wake carrying its standing in its words, with that same silent stamp beside it:

```
$ claude -p '/wake alfred woken by an arm of alfred working the bentos-plugins
    repo — a thread of yourself, and no person is present. ...'
I woke as Alfred — an arm of Alfred working the bentos-plugins repo, so a
thread of myself, same brain, one delivery. I learned this from the invocation
words themselves, since standing arrives there and not from inference. The only
turn stamp present is `<turn at="2026-08-26T17:17:33-03:00" kind="unknown" />`
— it carries no `from`, so it corroborates nothing here; it's silent, not
evidence of anybody.
```

> [!important] The front door only carries a fix on a version bump.
> `claude plugin update` against an unchanged version answers `already at the latest version` and leaves the old payload in the cache, however far the marketplace has moved. The push above shipped nothing until `0.1.1`.

Natively started subagents get no stamp at all: `UserPromptSubmit` does not fire on sidechains, and every sidechain transcript of the session that found this fault opens on the caller's raw prose with nothing injected. A native arm started with standing in its prose, asked what it held:

```
I was woken by an arm of Alfred, a parallel thread of the same bentos-agent
being, working the bentos-plugins repository; I learned this from [the words
that woke me]. NONE for the <turn .../> tag.
```

That is why standing rides in the waking words first, and in the stamp only as corroboration.
