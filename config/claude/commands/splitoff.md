---
description: Hand the current conversation off to a fresh background agent — write the handoff, then launch it with `claude --bg` seeded with that handoff as its prompt.
argument-hint: "[optional steer for the fresh agent]"
---

Hand **this conversation** off so a fresh agent can continue the work. The handoff is not saved for the user to read — it is the new agent's prompt.

`$ARGUMENTS`: optional steer (`只做完測試`, `skip the docs`). Empty = continue the current work as-is.

## 1. Write the handoff

The fresh agent sees none of this conversation, and starts in the **current working directory**. Give it only what was actually established here — no invention, no filler:

- **Goal** — what we are doing and why.
- **State** — what is done, what is half-done; branch, files touched (`file:line`), commands already run.
- **Next** — remaining steps in order, each with how it is verified (done = evidence, not narrative).
- **Constraints & decisions** — approaches already ruled out and why, conventions to follow, traps hit.
- **Open questions** — what is unresolved; the agent must ask, not guess.

Address the agent ("Continue …"), don't report about the conversation.

## 2. Launch it

Write the handoff to a temp file first, then pass it as the prompt — quoting it inline breaks on the backticks, `$`, and quotes a handoff normally contains.

```bash
claude --bg --name "<descriptive name>" --model "<this session's model>" "$(cat <handoff-file>)"
```

- `--bg` — starts as a background agent in the current working directory and returns immediately; the user manages it with `claude agents`.
- `--name` — always pass it (e.g. `--name "Fix login bug"`): it sets the display name in the job list, session picker, and terminal title.
- `--model` — always pass it: the model **this** session is running (an alias for the latest model, e.g. `--model opus`, or the exact name, e.g. `--model claude-opus-4-8`), so the fresh agent stays on it instead of falling back to the default.

Then report the agent's name, its model, and a one-line scope — nothing else.

ARGUMENTS: $ARGUMENTS
