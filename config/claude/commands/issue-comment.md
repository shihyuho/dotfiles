---
allowed-tools: Bash(gh issue comment:*), Bash(gh issue view:*), Bash(gh issue list:*), Bash(git rev-parse:*), Bash(ls:*), AskUserQuestion, Read
argument-hint: [issue-number] [file...]
description: Post one or more local files as comments on a GitHub issue (infers missing args from context, always confirms inferred values)
---

## Context

- Arguments received: "$ARGUMENTS"
- Current repo root: !`git rev-parse --show-toplevel 2>/dev/null || echo "(not a git repo)"`

## Your task

Post one or more local files as comments on a GitHub issue. Each file becomes its own comment; all comments are posted to the same issue.

### 1. Parse `$ARGUMENTS`

Two kinds of values are needed: **exactly one issue number** and **one or more file paths**. Order is flexible. Any of these shapes is valid:

- `614 docs/ideas/foo.md`
- `docs/ideas/foo.md 614`
- `#614 foo.md bar.md`
- `614 a.md b.md c.md`
- `docs/ideas/foo.md` (issue number missing)
- `614` (files missing)
- `` (both missing)

Heuristic: tokens that are pure digits (optionally prefixed with `#`) are the issue number; anything else is a file path. At most one issue number is allowed; any number of file paths is allowed. If two different issue numbers appear in `$ARGUMENTS`, stop and ask the user which one to use.

### 2. Fill in missing values from conversation context

For each value that was **not** explicitly provided in `$ARGUMENTS`:

**File path(s)** — prefer, in this order:
1. Files you just created or edited in the current conversation.
2. Markdown files recently discussed (e.g. a one-pager you were iterating on).
3. If still ambiguous, list plausible candidates with `ls` (e.g. `docs/ideas/*.md`, `docs/*.md`) and present choices.

**Issue number** — prefer, in this order:
1. An issue number explicitly mentioned in the conversation (e.g. "issue #614", "#614").
2. A number referenced alongside the file(s) you're about to post (e.g. the file's front-matter or opening line cites an issue).
3. If still ambiguous, run `gh issue list --limit 10 --state open` and present choices.

### 3. Confirm inferred values with the user — this step is required

Any value that was **inferred** (not explicitly supplied in `$ARGUMENTS`) MUST be confirmed via `AskUserQuestion` before posting. Values explicitly supplied in `$ARGUMENTS` do not need to be re-confirmed.

Rules:
- If **both** the issue and the file set are inferred, ask a single `AskUserQuestion` call with two questions (one per value), offering 2–4 candidates each.
- If **only one** is inferred, ask one question for that value.
- If **neither** is inferred, skip this step.
- When an inferred candidate is highly likely (e.g. the only `.md` file you just wrote), mark it `(Recommended)` and put it first.
- When confirming multiple files, show the full list (in posting order) so the user can drop or reorder them.

### 4. Sanity checks before posting

- Verify every file exists. If any is missing, stop and tell the user — do not post a partial set.
- Verify the issue exists and its state: `gh issue view <n> --json number,title,state`. If the issue is CLOSED, surface that to the user and confirm they still want to post.

### 5. Post the comments

For each file, in the order given, execute:

```
gh issue comment <n> --body-file <path>
```

Collect each returned URL.

### 6. Report

Summarise in one line per comment: which file was posted, to which issue, and the comment URL. No ceremony.

## Guardrails

- Do **not** modify or rewrite file contents before posting — post each file verbatim.
- Do **not** merge multiple files into a single comment — one file, one comment.
- Do **not** edit the issue title, labels, or type as part of this command.
- If `$ARGUMENTS` is empty AND the conversation has no plausible candidates for both the issue and at least one file, ask the user to supply them rather than guessing blindly.
