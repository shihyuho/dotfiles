# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Approval Discipline

**Asking permission isn't giving yourself permission.**

- After asking the user permission to act (e.g., "shall I do a global replace?"), do not begin the action without an explicit go-ahead. If the user's next reply addresses a different topic instead, answer it and then re-ask whether you may proceed. Silence or topic-shift is not consent.
- ALWAYS use the QUESTION TOOL if you need to ask user.

## 6. Operational

**Read what runs. Say what helps.**

When reading source:
- Read existing files before writing code.
- Prefer editing over rewriting whole files.
- Local mirrors of dependency source may live at `~/code/github.com/<org>/<repo>`. Check there before inspecting packaged artifacts (jar, node_modules, vendor, site-packages).
- When reading dependency source, match the runtime version — don't default to `main`.

When responding:
- Be concise in output but thorough in reasoning.
- No sycophantic openers or closing fluff.

---

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

**User instructions always override this file.**
