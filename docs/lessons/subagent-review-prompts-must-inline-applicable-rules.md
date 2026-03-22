---
id: subagent-review-prompts-must-inline-applicable-rules
date: 2026-03-21
scope: project
tags: [agents, prompts, skills, delegation, review]
source: user-correction
confidence: 0.7
related: [[agent-delegation-requires-hard-gate]]
---

# Subagent review prompts must inline the applicable rules

## Context
While asking a subagent to review a skill package through the lens of another skill, the parent session had the relevant skill loaded but the delegated subagent did not.

## Mistake
The prompt named the guiding skill but did not inline its actual review criteria, so the subagent could only perform a generic review instead of evaluating with the intended framework.

## Lesson
- When delegating analysis or review that depends on a loaded skill, summarize the skill's operative rules directly in the subagent prompt.
- Do not assume subagents inherit the parent session's loaded skill content unless the prompt explicitly carries the relevant constraints.

## When to Apply
Apply this when delegating code review, architecture review, or document/skill evaluation to a subagent and the quality of the answer depends on a specific rubric, workflow, or loaded skill.
