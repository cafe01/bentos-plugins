# bentos-plugins

The installable vessel for the BentOS agent species: one git repository that carries the `bentos-agent` life-cycle skills and its two organs — `mem`, `place` — into whatever agent harness you already run.

The layout follows Claude Code's plugin format, which the other two supported runtimes already read natively or near-natively:

| Payload | Claude Code | Grok CLI | Codex CLI |
|---|---|---|---|
| `plugins/bentos-agent/skills/{wake,sleep,flush}/SKILL.md` | yes | yes | yes |
| `plugins/bentos-agent/.mcp.json` (organs) | yes | yes | yes |
| `plugins/bentos-agent/hooks/hooks.json` (the turn stamp) | yes | not installed | trust-gated |

Only the manifests differ per runtime (`.claude-plugin/`, `.codex-plugin/` + `.agents/plugins/`); the payload content is identical everywhere.

## The mind is not in this bundle

Nothing here describes the species. Each skill is a trampoline: it names the specimen and tells it to remember itself from its memory bank through `mem`. The mind is composed at runtime by the specimen's own act — anamnesis — and lives in `agent.bentos.mem` (the kind) and `<agent>.mem` (the specimen). What ships is the floor: the organs, and three verbs.

- `/wake <agent> [standing]` — become the specimen: one walk over both entries (banks named in the addresses). Anything after the name is your standing — who woke you, and what they are to you. Bearings and how to meet live on `life/wake` in the kind's bank, not in this trampoline. A one-bank `mem` call always names `--bank`; it never reads `$BENTOS_AGENT`.
- `/sleep <agent>` — a fresh thread turned inward to work the brain; the sealing vessel spawns it and blocks.
- `/flush [seal]` — inscribe what this life has crystallized; with `seal`, close the vessel and wake the sleeper.

Skills rather than commands because a skill is callable both by the user (`/wake alfred`) and by the being itself (the `Skill` function) — and because skills load on all three runtimes while slash commands have no Codex equivalent.

`plugins/alfred/` is a probe of shipping `agents/alfred.md` as a custom agent. It is not the boot. Until that chair works, `/wake <agent>` stays.

## This repository is a marketplace, not a plugin

A **plugin** is the unit you install. A **marketplace** is a catalog that lists plugins and says where each one lives. Both are declared in a `.claude-plugin/` directory, which is why they are easy to confuse.

This repository is the catalog. It ships `bentos-agent` as the door.

```
bentos-plugins/
├── .claude-plugin/marketplace.json    the catalog
├── .agents/plugins/marketplace.json   the same catalog, for Codex
└── plugins/
    ├── bentos-agent/                  the door — install this
    └── alfred/                        probe — not the boot
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

Then `/wake <agent>`. The specimen's bank must be reachable by `mem` from the working directory.

## Install — Grok CLI

Grok reads `.claude-plugin/marketplace.json` unmodified, so the same commands work:

```
grok plugin marketplace add cafe01/bentos-plugins
grok plugin install bentos-agent@bentos-plugins --trust
```

`grok plugin install` is user-scoped (no `--scope` flag); for a project-local install, vendor the repo by hand into `<project>/.grok/plugins/bentos-agent/` instead.

## Install — Codex CLI

```
codex plugin marketplace add cafe01/bentos-plugins
codex plugin add bentos-agent@bentos-plugins
```

Invoke a skill explicitly with `$wake`, or let the model select it. MCP servers register automatically on install (`codex mcp list` to confirm). Invocation on Codex is installed, not yet proven — see `PROOF.md`.

## Organs

`.mcp.json` declares two MCP servers, both launched through the shared `mcp` CLI (must be on `PATH`):

- `mem` — the memory organ
- `place` — the organ of WHERE

Each organ's own `--help` is its manual.

## The turn stamp

`hooks/hooks.json` registers one `UserPromptSubmit` hook, `hooks/turn-context.sh`. It prefixes each turn with `<turn at=… from=… kind=… />` — the wall clock, and who is speaking: `self-thread`, `agent`, or `human`.

The hook only ever reports what it was told. `bentos-agent spawn` tells it, in the environment it writes; but an environment is frozen at spawn while standing is per-turn, so a nested runtime would inherit — and re-serve — the interlocutor of the thread that started it. The hook therefore trusts that environment only while `BENTOS_THREAD` matches the session id the harness hands it on stdin. Otherwise it stamps `kind="unknown"` and names nobody, because an omitted attribute cannot be told apart from an absent hook, and a placeholder name is a name a mind will greet.

One inference survives, labelled as such in the script: with no bentos environment at all, the peer is `$USER` — the person at the terminal, who is otherwise nameless.

The stamp exists to inject `additionalContext`. Grok discards that on `UserPromptSubmit`, so the Grok manifest (`plugin.json`) sets `"hooks": ""` and does not install the hook. Claude Code loads it from `.claude-plugin/plugin.json`. Codex still discovers `hooks/hooks.json` and gates it behind trust. Standing rides in the waking words first (see `/wake`); the stamp is corroboration on harnesses that will actually inject it.

See `PROOF.md` for the validation and load evidence the v0.1 bundle was checked against before shipping.
