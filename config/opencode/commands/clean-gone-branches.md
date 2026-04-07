---
description: Clean up local branches deleted on remote
agent: build
model: opencode/minimax-m2.5-free
subtask: true
---

Clean up all local git branches whose remote tracking branch has been deleted (marked as `[gone]`), including removing associated worktrees.

## Steps

1. Fetch and prune remote references: `git fetch --prune`
2. List all local branches: `git branch -v`
3. List all worktrees: `git worktree list`
4. For each branch marked `[gone]`:
   - If the branch has an associated worktree, remove the worktree first with `git worktree remove`
   - Delete the branch with `git branch -D`
5. Report what was cleaned up, or confirm nothing needed cleanup

## Rules

- Never remove the current branch or the main repository worktree
- Remove worktrees before deleting their associated branches

<user-request>
$ARGUMENTS
</user-request>
