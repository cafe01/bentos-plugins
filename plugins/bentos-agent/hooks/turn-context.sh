#!/usr/bin/env bash
# UserPromptSubmit hook: injects a <turn/> tag — wall-clock time, and who is
# speaking this turn — into the prompt's context. Fires on EVERY turn of EVERY
# session, so it must never fail a turn: no set -e, no required variable, and
# always exit 0.
#
# Standing is told, never inferred. `bentos-agent spawn` does the telling, in
# the environment it writes when it starts a thread. But an environment is
# per-process and frozen at spawn, while standing is per-turn: every descendant
# process inherits a peer that describes the thread which started it, never
# itself. A nested runtime therefore re-serves its ancestor's interlocutor as
# its own — the fault observed on 2026-08-26, where a thread no person attended
# read `kind="human"`.
#
# The cure is a freshness test. BENTOS_THREAD names the session the environment
# was written for; the harness names the running session on this hook's stdin.
# Equal, the environment still speaks for this thread. Unequal, it belongs to an
# ancestor and this hook knows nothing — and says so.

at=$(date +%Y-%m-%dT%H:%M:%S%z)
at="${at:0:22}:${at:22}"

# One line of stdin, or none. A runtime that pipes nothing must not hang a turn.
input=""
IFS= read -r -t 2 input

session=$(printf '%s' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

agent="${BENTOS_AGENT:-}"
thread="${BENTOS_THREAD:-}"
peer=""
kind=""

if [ -z "$agent" ] && [ -z "$thread" ]; then
  # No bentos environment at all: nothing started this session but a shell.
  #
  # THE SURVIVING INFERENCE. $USER is machine ownership, which is a guess and
  # not a telling. It holds for a person at a terminal, and it is wrong for
  # anything unattended that reaches this branch. It is kept because the person
  # at the keyboard is otherwise nameless, and it is labelled here because a
  # guess that is not marked becomes a fact at the next reading. Every other
  # branch below reports what it was told.
  peer="${USER:-}"
  kind="human"
elif [ -n "$thread" ] && [ "$thread" = "$session" ]; then
  # The environment describes THIS session, so what spawn wrote is still true.
  peer="${BENTOS_PEER:-}"
  if [ "$peer" = "$agent" ]; then
    kind="self-thread"
  elif [ "$peer" = "${USER:-}" ]; then
    # Derived, but from a fresh telling: spawn writes $USER as the peer exactly
    # when a person ran it. The channel carries the name and not the kind.
    kind="human"
  else
    kind="agent"
  fi
fi

# Not knowing is stated, never left blank: an absent attribute cannot be told
# apart from an absent hook, and a placeholder name is a name a mind will greet.
if [ -z "$peer" ]; then
  payload="<turn at=\\\"$at\\\" kind=\\\"unknown\\\" />"
else
  payload="<turn at=\\\"$at\\\" from=\\\"$peer\\\" kind=\\\"$kind\\\" />"
fi

printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$payload"
exit 0
