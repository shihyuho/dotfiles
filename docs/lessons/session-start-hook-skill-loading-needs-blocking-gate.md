---
id: session-start-hook-skill-loading-needs-blocking-gate
date: 2026-06-11
scope: project
tags: [hooks, skills, prompts, session-start, claude]
source: retrospective
confidence: 0.7
related: [[agent-delegation-requires-hard-gate]], [[subagent-review-prompts-must-inline-applicable-rules]]
---

# SessionStart hook skill-loading needs a blocking gate, not a statement

## Context
`config/claude/hooks/using-skills.sh` emits `additionalContext: "Invoke the skills: planning-with-files, git-workflow-and-versioning, artifact-anatomy."` In a real session the agent loaded none of them and worked the whole way through without them; the gap only surfaced because the user asked.

## Mistake
The instruction was a passive statement buried among other startup context — no blocking language, no timing ("before X"), no rationale, no failure handling. SessionStart context is injected before any user turn, so the model files it as background and prioritizes the user's actual first request over it.

## Lesson
- `additionalContext` reliably *injects*, but injection ≠ the model *acting*. If an action must happen, prefer making the hook do it deterministically (inject the rules/content themselves) over asking the model to go invoke something.
- If the model must still load skills, phrase it as a blocking gate: "Before responding to the first message or calling any other tool, call the Skill tool once for each: …", plus a one-line why and a failure fallback. Same family as [[agent-delegation-requires-hard-gate]].
- Bind mandatory actions to the first user turn (UserPromptSubmit, fired once via a flag file) rather than SessionStart — the model is most responsive to "what this turn asks."
- Question whether every session truly needs these skills. If it's conditional, encode the trigger ("when committing, load git-workflow-and-versioning") instead of an unconditional load that reads as noise and gets skipped.

## When to Apply
Apply when writing SessionStart / UserPromptSubmit `additionalContext`, or any always-on instruction that expects the model to take a concrete action (load a skill, call a tool) before doing the user's work.
