---
description: Git commit, push and open a pull request
agent: build
model: opencode/minimax-m2.5-free
subtask: true
---

commit, push and open a pull request

make sure it uses the conventional commit format

prefer to explain WHY something was done from an end user perspective instead of
WHAT was done.

do not do generic messages like "improved agent experience" be very specific
about what user facing changes were made

if there are conflicts DO NOT FIX THEM. notify me and I will fix them

## GIT DIFF

!`git diff`

## GIT DIFF --cached

!`git diff --cached`

## GIT STATUS --short

!`git status --short`

<user-request>
$ARGUMENTS
</user-request>
