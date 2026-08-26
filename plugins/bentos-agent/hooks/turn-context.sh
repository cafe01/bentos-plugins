#!/usr/bin/env bash
# UserPromptSubmit hook: injects a <turn/> tag (wall-clock time + peer
# identity) into the prompt's context for this turn. Fires on EVERY turn of
# EVERY session — must never fail a turn. No set -e, no required vars:
# missing env degrades to the minimal <turn at="..." /> tag. Always exit 0.

at=$(date +%Y-%m-%dT%H:%M:%S%z)
at="${at:0:22}:${at:22}"

peer="${BENTOS_PEER:-}"
agent="${BENTOS_AGENT:-}"

# No BENTOS_AGENT means this vessel was never spawned by bentos-agent — a
# human is driving it directly, so the peer is whoever is at the keyboard.
if [ -z "$agent" ]; then
  peer="${USER:-}"
fi

if [ -z "$peer" ]; then
  payload="<turn at=\\\"$at\\\" />"
else
  if [ "$peer" = "$agent" ]; then
    kind="self-thread"
  elif [ "$peer" = "${USER:-}" ]; then
    kind="human"
  else
    kind="agent"
  fi
  payload="<turn at=\\\"$at\\\" from=\\\"$peer\\\" kind=\\\"$kind\\\" />"
fi

printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$payload"
exit 0
