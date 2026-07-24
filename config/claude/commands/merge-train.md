---
allowed-tools: Bash(gh repo view:*), Bash(gh pr list:*), Bash(gh pr view:*), Bash(gh pr merge:*), Bash(gh pr update-branch:*), Bash(gh api:*), Bash(git rev-parse:*), Read, Write, AskUserQuestion
argument-hint: "[pr numbers…] [--method squash|merge|rebase] [--check <context>] [--timeout <seconds>]; empty = PRs discussed in context, else auto-discover approved PRs"
description: Land every approved PR on the default branch one at a time, driving auto-merge through a serialized update-branch queue
---

## Context

- Arguments received: "$ARGUMENTS"
- Repo: !`gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true`
- Default branch: !`gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null || true`
- Merge methods allowed: !`gh repo view --json squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed,deleteBranchOnMerge 2>/dev/null || true`
- Auto-merge allowed: !`gh api "repos/$(gh repo view --json nameWithOwner --jq .nameWithOwner)" --jq .allow_auto_merge 2>/dev/null || true`
- Rules on the default branch: !`gh api "repos/$(gh repo view --json nameWithOwner --jq .nameWithOwner)/rules/branches/$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)" 2>/dev/null || true`

## Your task

Land every approved open PR on the default branch, oldest first, by arming GitHub auto-merge on each one and then feeding them through the required-checks gate one at a time.

The reason this needs a command rather than a `for` loop: when the branch ruleset requires branches to be **up to date** before merging, only one PR can be mergeable at a time. Each merge moves the default branch, which makes every other PR stale again. So the queue has to be driven serially — update the head PR, wait for its checks, let auto-merge land it, then update the next one.

Nothing here merges a PR that GitHub would not merge on its own. Auto-merge does the merging; this command only decides the order and pushes branches forward.

### 1. Parse `$ARGUMENTS`

- Bare numbers (optionally `#`-prefixed) — an explicit PR queue. When given, skip discovery in step 3 and use exactly these, **in the order written**. Still run the approval and staleness report on them so the user sees what they are about to land.
- `--method squash|merge|rebase` — merge method. When omitted, derive it in step 2.
- `--check <context>` — a required check context, repeatable. When omitted, derive it in step 2.
- `--timeout <seconds>` — per-PR wait budget. Default `2700` (45 minutes).
- Empty — infer before discovering. When the conversation so far makes it unambiguous which PRs this run is about, use those as the queue — same handling as an explicit queue (skip discovery in step 3, still run the approval and staleness report), except sorted by `createdAt` oldest first, since conversation order carries no ordering intent. Label the queue "inferred from conversation" in the step-4 plan so a wrong inference is visible before anything runs. Any doubt about which PRs were meant → discover the queue in step 3.

### 2. Establish the repo's merge rules

Read them from the Context block above; re-query only what is missing or ambiguous.

**Merge method.** Use `gh repo view --json squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed`, not the REST `allow_*` fields — REST returns `null` for all of them unless the token has write access on the repo, while the GraphQL-backed fields are always populated. If exactly one method is allowed, use it without asking. If several are, and the user did not pass `--method`, ask which. Passing a method the repo has disabled fails at merge time.

**Auto-merge.** `allow_auto_merge` in the Context block is REST-only and has the same access caveat: `null` means "could not read", not "disabled". Treat `false` as a hard stop (tell the user to enable auto-merge in repo settings), and `null` as unknown — proceed and let `gh pr merge --auto` surface the error.

**Branch rules.** Read `repos/{owner}/{repo}/rules/branches/{branch}`, as the Context block does. Do **not** rely on `repos/{owner}/{repo}/branches/{branch}/protection` — it returns 404 "Branch not protected" whenever the rules come from a ruleset rather than classic branch protection, which reads as "no rules" when the branch is in fact heavily guarded. The `rules/branches` endpoint returns every rule in effect, repository-level and organization-level together. From the response:

- rule `type: "required_status_checks"` → `parameters.required_status_checks[].context` is the check list; `parameters.strict_required_status_checks_policy` says whether branches must be up to date.
- rule `type: "pull_request"` → `parameters.required_approving_review_count` and `parameters.dismiss_stale_reviews_on_push`.

**If `strict_required_status_checks_policy` is false or there is no `required_status_checks` rule, say so and stop before step 6.** Serialization exists only to satisfy the up-to-date requirement. Without it, the right move is to arm auto-merge on the whole queue at once and let GitHub land them in whatever order the checks finish — offer that instead, and run step 5 only.

### 3. Build the queue

Fetch every open PR with the review and commit history attached:

```bash
gh pr list --state open --limit 100 \
  --json number,title,createdAt,isDraft,author,headRefName,reviews,commits,autoMergeRequest \
  --jq '[ .[]
    | select(.isDraft | not)
    | . as $pr
    | ([$pr.reviews[] | select(.state != "COMMENTED")]
        | group_by(.author.login)
        | map(sort_by(.submittedAt) | last)) as $latest
    | { number: $pr.number,
        title: $pr.title,
        author: $pr.author.login,
        createdAt: $pr.createdAt,
        approvals: ([$latest[] | select(.state == "APPROVED")] | length),
        changesRequested: ([$latest[] | select(.state == "CHANGES_REQUESTED")] | length),
        lastApprovalAt: ([$latest[] | select(.state == "APPROVED") | .submittedAt] | max),
        lastCommitAt: ([$pr.commits[].committedDate] | max),
        autoMerge: ($pr.autoMergeRequest != null) } ]
    | sort_by(.createdAt)'
```

A PR is approved when `approvals > 0` and `changesRequested == 0`.

**Do not use `reviewDecision` for this.** When the ruleset's `required_approving_review_count` is `0`, GitHub returns an empty string in `reviewDecision` for PRs that carry real approvals — only `CHANGES_REQUESTED` ever shows up. Trusting that field silently drops every approved PR in exactly the repos where this command is most useful. The reduction above is the reliable read: per reviewer, the latest review that is not `COMMENTED`.

A PR is **stale-approved** when `lastApprovalAt < lastCommitAt` — someone approved, then more code landed. If `dismiss_stale_reviews_on_push` is `false`, GitHub still counts it as approved and will happily merge it, even though no human has looked at the current diff.

Report the split — fresh approvals, stale approvals, and everything excluded with the reason — then **ask the user whether the stale ones go in**. Never decide this silently in either direction. Only offer the choice if there actually are stale PRs.

Sort the final queue by `createdAt`, oldest first.

### 4. Confirm the plan

Show, in one table: queue order, PR number, title, author, approval freshness, and whether auto-merge is already armed. Below it, state the merge method, the required checks being waited on, and the per-PR timeout. Get explicit confirmation before touching anything.

### 5. Arm auto-merge

For each PR in the queue, in order:

```bash
gh pr merge <number> --auto --<method>
```

Skip any PR whose `autoMerge` is already `true`. Do not pass `--delete-branch` — the repo's `deleteBranchOnMerge` setting already covers it, and forcing it overrides the maintainers' choice.

Arming is not merging: with a strict up-to-date policy in force, every PR except the head of the queue sits idle until its branch is updated. A PR that is already up to date and green may merge the instant it is armed — that is fine and expected.

### 6. Drive the queue

Write the script below to the scratchpad, substituting the placeholders, and run it **in the background** — it sleeps between polls, and a foreground sleep is blocked.

```bash
#!/bin/bash
# merge-train driver — advance an armed auto-merge queue one PR at a time.
REPO="<owner/name>"
PRS="<space-separated PR numbers, in queue order>"
REQUIRED_CHECKS="<space-separated check contexts; empty = do not gate on checks>"
PER_PR_TIMEOUT=2700   # per-PR wait budget from step 1
STALE_LIMIT=600       # how long a head/ref mismatch may persist before aborting
POLL=45

ts() { date -u +%H:%M:%SZ; }

# Latest state of one required check on one commit. Commit statuses cover
# external CI (Jenkins, CircleCI); check-runs cover GitHub Actions and apps.
check_state() {
  local sha="$1" ctx="$2" s
  [ -z "$sha" ] && return
  s=$(gh api "repos/$REPO/commits/$sha/status" \
        --jq "[.statuses[] | select(.context == \"$ctx\")] | last | .state" 2>/dev/null)
  if [ -n "$s" ] && [ "$s" != "null" ]; then echo "$s"; return; fi
  # `last` on an empty array yields null — report that as "no such check yet",
  # not as pending, so a wrong context name is visible in the log instead of
  # looking like a check that never finishes.
  gh api "repos/$REPO/commits/$sha/check-runs" \
    --jq "[.check_runs[] | select(.name == \"$ctx\")] | last
          | if . == null then empty
            elif .status != \"completed\" then \"pending\"
            else (.conclusion // \"pending\") end" 2>/dev/null
}

for n in $PRS; do
  echo "================ PR #$n ================"

  branch=$(gh pr view "$n" --repo "$REPO" --json headRefName --jq .headRefName)
  head_repo=$(gh pr view "$n" --repo "$REPO" \
                --json headRepositoryOwner,headRepository \
                --jq '.headRepositoryOwner.login + "/" + .headRepository.name')

  echo "[$(ts)] #$n update-branch ($head_repo:$branch)"
  if ! gh pr update-branch "$n" --repo "$REPO" 2>&1; then
    echo "[$(ts)] #$n update-branch FAILED — stopping"
    exit 1
  fi

  deadline=$(( $(date +%s) + PER_PR_TIMEOUT ))
  stale_since=0

  while [ "$(date +%s)" -lt "$deadline" ]; do
    sleep "$POLL"

    state=$(gh pr view "$n" --repo "$REPO" --json state --jq .state 2>/dev/null)
    case "$state" in
      MERGED)
        echo "[$(ts)] #$n MERGED at $(gh pr view "$n" --repo "$REPO" --json mergedAt --jq .mergedAt)"
        break ;;
      CLOSED)
        echo "[$(ts)] #$n closed without merging — stopping"
        exit 1 ;;
    esac

    # The branch ref is the truth; the PR object's head.sha lags behind it.
    head=$(gh api "repos/$REPO/pulls/$n" --jq .head.sha 2>/dev/null)
    ref=$(gh api "repos/$head_repo/git/ref/heads/$branch" --jq .object.sha 2>/dev/null)

    verdict=""
    for ctx in $REQUIRED_CHECKS; do
      st=$(check_state "$ref" "$ctx")
      verdict="$verdict $ctx=${st:-none}"
      case "$st" in
        failure|error|timed_out|action_required|cancelled|startup_failure)
          echo "[$(ts)] #$n required check $ctx = $st on ${ref:0:7} — stopping"
          exit 1 ;;
      esac
    done

    sync=ok
    if [ -n "$ref" ] && [ "$head" != "$ref" ]; then
      [ "$stale_since" -eq 0 ] && stale_since=$(date +%s)
      sync="STALE(pr=${head:0:7} ref=${ref:0:7}, $(( $(date +%s) - stale_since ))s)"
    else
      stale_since=0
    fi

    echo "[$(ts)] #$n state=$state ref=${ref:0:7}$verdict sync=$sync"

    if [ "$stale_since" -ne 0 ] && [ $(( $(date +%s) - stale_since )) -gt "$STALE_LIMIT" ]; then
      echo "[$(ts)] #$n head stuck at ${head:0:7} while $branch is at ${ref:0:7} (>${STALE_LIMIT}s)."
      echo "        CI most likely never received a synchronize event for ${ref:0:7}."
      echo "        Fix: push an empty commit to $branch, or close and reopen #$n, then re-run. — stopping"
      exit 1
    fi
  done

  if [ "$(gh pr view "$n" --repo "$REPO" --json state --jq .state)" != "MERGED" ]; then
    echo "[$(ts)] #$n still not merged after ${PER_PR_TIMEOUT}s — stopping"
    exit 1
  fi
done

echo "[$(ts)] merge train complete"
```

Poll the background output periodically rather than continuously. Report progress as PRs land, and when the script exits non-zero, surface its last lines verbatim — they carry the diagnosis.

### 7. Report

State what merged (with merge commit SHAs), what is still open and why, and anything the user deliberately excluded. If the run aborted mid-queue, name the PR it stopped on, the reason, and what re-running would do — the command is re-runnable, and already-merged PRs simply drop out of discovery.

## Field notes

Diagnostics that cost real time to work out. Apply them before concluding anything about a stuck PR.

- **`mergeStateStatus: "BLOCKED"` does not mean a check failed.** Under a strict up-to-date policy, "branch is behind base" reports as blocked too. To tell them apart, read `repos/{owner}/{repo}/compare/{base}...{head}` for `behind_by`, and read the required checks on the head commit separately. Do not tell the user CI failed on the strength of `BLOCKED` alone.

- **A PR object's `head.sha` goes stale after `gh pr update-branch`.** Both REST and GraphQL can keep serving the pre-update SHA for a while. `repos/{owner}/{repo}/git/ref/heads/{branch}` is authoritative. This is why the driver evaluates checks against `ref` and treats a persistent `head != ref` as the abort signal it is: when that gap outlives the checks, CI never saw the merge commit `update-branch` created, and no amount of waiting will produce a status on it.

- **Cross-repo PRs live in the fork.** `git/ref/heads/{branch}` has to be read from `headRepositoryOwner/headRepository`, not the base repo. The driver already does this; keep it that way if you edit the script.

- **Check names come from two different APIs.** External CI posts commit *statuses* (`context`); GitHub Actions and apps post *check-runs* (`name`). A required check listed in a ruleset can be either, so `check_state` tries both before giving up.

## Guardrails

- Never merge with a bare `gh pr merge`. `--auto` is the whole safety model here: GitHub enforces the rules, and a PR that stops satisfying them stops merging.
- Never bypass, disable, or edit a ruleset or branch protection to get a PR through. If the rules block the queue, report it and stop.
- Never push commits, amend, or rebase locally to unstick a PR. Recommend the fix (empty commit, close/reopen) and let the user run it.
- Never include a PR the user excluded, and never quietly promote a stale-approved PR into the queue.
- Do not commit anything in the current repo as part of this command.
