---
allowed-tools: Bash(gh issue comment:*), Bash(gh issue view:*), Bash(gh issue list:*), Bash(gh pr comment:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(git rev-parse:*), Bash(ls:*), Write, AskUserQuestion, Read
argument-hint: [number] [file...]
description: Post local files (or stashed chat content) as comments on a GitHub issue or pull request (infers missing args from context, always confirms inferred values)
---

## Context

- Arguments received: "$ARGUMENTS"
- Current repo root: !`git rev-parse --show-toplevel 2>/dev/null`

## Your task

Post one or more local files as comments on a GitHub **issue or pull request**. Each file becomes its own comment; all comments are posted to the same target.

If no file path is given but the conversation has substantial AI-authored content the user is clearly referring to (e.g. a review report, code analysis, proposal, summary printed inline rather than saved to disk), you may stash that content to a temp file under `/tmp/` and post it from there. The point is to remove the manual "save then post" round-trip when the content is already on screen.

Issues and PRs share a single number namespace per repo, so a given number resolves to *either* an issue or a PR — never both. The target type is detected automatically in step 4.

### 1. Parse `$ARGUMENTS`

Two kinds of values are needed: **exactly one number** (issue or PR) and **one or more file paths**. Order is flexible. Any of these shapes is valid:

- `614 docs/ideas/foo.md`
- `docs/ideas/foo.md 614`
- `#614 foo.md bar.md`
- `614 a.md b.md c.md`
- `docs/ideas/foo.md` (number missing)
- `614` (files missing)
- `` (both missing)

Heuristic: tokens that are pure digits (optionally prefixed with `#`) are the target number; anything else is a file path. At most one number is allowed; any number of file paths is allowed. If two different numbers appear in `$ARGUMENTS`, stop and ask the user which one to use.

### 2. Fill in missing values from conversation context

For each value that was **not** explicitly provided in `$ARGUMENTS`:

**File path(s)** — prefer, in this order:
1. Substantial AI-authored content in the most recent assistant turn that the user is clearly referring to (e.g. a review report, code analysis, proposal, summary printed inline rather than saved). Plan to stash it to `/tmp/post-gh-comment-<UTC-ISO-timestamp>.md` (e.g. `/tmp/post-gh-comment-20260505T143022Z.md`) — **but do not write the file yet**; the content must be confirmed in step 3 first. Skip this priority if the most recent assistant content is just a brief reply (a short answer, a yes/no, a one-paragraph note) — only stash content that's plausibly comment-shaped.
2. Files you just created or edited in the current conversation.
3. Markdown files recently discussed (e.g. a one-pager you were iterating on).
4. If still ambiguous, list plausible candidates with `ls` (e.g. `docs/ideas/*.md`, `docs/*.md`) and present choices.

**Number** — prefer, in this order:
1. An issue or PR number explicitly mentioned in the conversation (e.g. "issue #614", "PR #42", "#614").
2. A number referenced alongside the file(s) you're about to post (e.g. the file's front-matter or opening line cites an issue or PR).
3. If still ambiguous, run both `gh issue list --limit 10 --state open` and `gh pr list --limit 10 --state open`, then present choices labelled with their type (issue / PR).

### 3. Confirm inferred values with the user — this step is required

Any value that was **inferred** (not explicitly supplied in `$ARGUMENTS`) MUST be confirmed via `AskUserQuestion` before posting. Values explicitly supplied in `$ARGUMENTS` do not need to be re-confirmed.

Rules:
- If **both** the number and the file set are inferred, ask a single `AskUserQuestion` call with two questions (one per value), offering 2–4 candidates each.
- If **only one** is inferred, ask one question for that value.
- If **neither** is inferred, skip this step.
- When an inferred candidate is highly likely (e.g. the only `.md` file you just wrote), mark it `(Recommended)` and put it first.
- When confirming multiple files, show the full list (in posting order) so the user can drop or reorder them.
- When listing number candidates, label each with whether it is an issue or a PR.
- **When the file source is stashed chat content**, do NOT cram the preview into the `AskUserQuestion` itself — its option label/description fields are short and a 20-line markdown block will either be truncated or drown out the actual choices. Instead:
  1. First, print a normal text message to the user containing: the planned `/tmp/...` path, the line/character count of the content, and a fenced code block with the first ~20 lines (followed by `...` if truncated).
  2. Then call `AskUserQuestion` with a tight confirm widget — e.g. options like `Post it`, `Cancel`, `Show full content first`. Keep all option labels under ~60 characters.

### 4. Stash chat content (if applicable) and run sanity checks

- If the chosen file is stashed chat content and the user has confirmed it, use `Write` now to create the file at the planned `/tmp/post-gh-comment-<UTC-ISO-timestamp>.md` path with the **verbatim** content. Do not edit, summarise, trim, or reformat — what was on screen is what gets written.
- Verify every file exists. If any is missing, stop and tell the user — do not post a partial set.
- Detect target type and verify state. Try issue first, fall back to PR:
  ```
  gh issue view <n> --json number,title,state 2>/dev/null \
    || gh pr view <n> --json number,title,state,isDraft
  ```
  Whichever subcommand succeeds determines the target type. Remember it for step 5.
- If the target is CLOSED (issue) or CLOSED / MERGED (PR), surface that to the user and confirm they still want to post. Posting on a draft PR is fine but worth mentioning.
- If neither subcommand returns a record, stop — the number does not exist in this repo.

### 5. Post the comments

For each file, in the order given, execute the variant matching the detected type:

- Issue: `gh issue comment <n> --body-file <path>`
- PR:    `gh pr comment <n> --body-file <path>`

Collect each returned URL.

### 6. Report

Summarise in one line per comment: which file was posted, to which target (issue or PR, with number), and the comment URL. If any file was a stashed chat-content temp file, include its `/tmp/...` path on that line so the user can grep, edit, or re-post it later. No ceremony.

## Guardrails

- Do **not** modify or rewrite file contents before posting — post each file verbatim. This applies equally to stashed chat content: write what was printed, exactly.
- Do **not** merge multiple files into a single comment — one file, one comment.
- Do **not** edit the target's title, labels, type, reviewers, or any other metadata as part of this command.
- Do **not** delete the stash temp file after posting — leave it in `/tmp/` so the user can reuse, audit, or re-post it.
- If `$ARGUMENTS` is empty AND the conversation has no plausible candidates for both the number and at least one file (including no chat content worth stashing), ask the user to supply them rather than guessing blindly.
