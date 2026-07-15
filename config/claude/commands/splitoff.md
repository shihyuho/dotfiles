---
description: Hand the current conversation off to a fresh background agent that picks up the work immediately.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Follow the `/handoff` skill to write a summary of the current conversation so a fresh agent can continue the work. It is user-invoked (`disable-model-invocation`), so the Skill tool won't fire it — read its `SKILL.md` instead and follow it directly. The summary is not for the user to read — it is the fresh agent's prompt.

Launch the agent with the file `/handoff` wrote: `claude --bg --name "<descriptive name>" --model "<model>" -- "$(cat <handoff-file>)"`. Pass it as a path — quoting the summary inline breaks on the backticks, `$`, and quotes a handoff normally contains. Keep the `--`: without it a summary that opens with `-` (a YAML frontmatter fence, a bullet) is parsed as a flag and the launch dies. The command returns immediately; the agent runs in the current working directory and the user manages it with `claude agents`.

Always pass `-n`/`--name` with a short descriptive name: derive it from `ARGUMENTS` when the user gave one, otherwise from the handed-off work (e.g. `--name "Fix login bug"`). It sets the display name shown in the job list, session picker, and terminal title.

Always pass `--model`: the model the user named in `ARGUMENTS` if they named one, otherwise the model **this** session is running (either an alias for the latest model, e.g. `--model opus`, or the exact name, e.g. `--model claude-opus-4-8`). Never let the fresh agent fall back to the default.

ARGUMENTS: $ARGUMENTS
