---
id: agent-delegation-requires-hard-gate
date: 2026-03-07
scope: project
tags: [agents, prompts, delegation, subagents, opencode]
source: retrospective
confidence: 0.3
related: []
---

# Agent delegation needs a hard gate, not preference wording

## Context
An opencode root agent was instructed to never work alone when specialists were available, but stronger GPT variants still completed work directly instead of delegating to subagents.

## Mistake
The prompt described delegation as an operating preference while also giving the root agent broad authority to investigate and implement directly. That left enough room for the model to optimize for speed and skip subagent calls.

## Lesson
- When delegation is mandatory, encode it as a blocking decision gate with explicit allowed exceptions.
- Limit direct execution to clearly defined cases such as trivial answers or unavailable subagents.
- Remove or rewrite any nearby language that frames subagents as optional accelerators or broadens root-agent autonomy in ways that conflict with mandatory delegation.

## When to Apply
Apply this when editing root-agent prompts, orchestration prompts, or any instruction set that expects a model to call specialist agents or task tools before doing substantive work itself.
