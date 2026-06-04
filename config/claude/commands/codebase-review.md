---
description: Author and run a tailored multi-audit workflow (bug hunt + static optimization + security) over the codebase, with a design sign-off gate and a pre-run sign-off gate, then emit a Traditional Chinese report (HTML or Markdown).
argument-hint: [optional hints, e.g. "security only", "src/ only", "diff"]
---

## What this command does

Run a **codebase-wide review** by authoring a fresh dynamic workflow per run (it is
not a fixed pre-written workflow), then executing it. The workflow fans out parallel
finders, adversarially verifies every finding, and returns structured results that
this session renders into a report.

Three audit types are available:

- `bug` — codebase-wide bug hunt (correctness, edge cases, resource leaks, races)
- `perf` — **static** optimization audit (algorithmic complexity, N+1 queries,
  needless allocation/copying, blocking calls on hot paths)
- `security` — security audit (injection, authz/authn gaps, secret handling, unsafe deserialization)

> **Honesty caveat — say this to the user up front.** A workflow agent only reads
> source statically; it cannot run a real profiler. "Profiler-guided optimization"
> here means *static* hotspot reasoning, not runtime profiling data. If the user
> wants real profiler numbers, that must be captured by actually running the app and
> fed in separately. Label the perf section as **靜態最佳化稽核** in the report.

There are **two gates**:

1. **Design gate** — present this run's design considerations **before writing the workflow file**.
2. **Pre-run gate** — after writing the workflow file, **before running it**.

Each gate is **independent** and defaults to **on (pause for approval)**, but the user
chooses in Step 1 whether to pause at each one or run straight through in one shot.
Whichever gates are off, still *show* the design / workflow path in the transcript —
just do not block.

`$ARGUMENTS` may carry hints (audit type, scope, format, gate mode). Treat them as
defaults to confirm, not as permission to skip the Step 1 questions.

## Step 1 — Ask the knobs (before anything else)

Ask the user (one consolidated round) and confirm:

- **Audit types** — which of `bug` / `perf` / `security`. Default: **all three**.
- **Scope** — whole repo (default) / only `git diff` changed files / a path or glob.
- **Depth** — `low` / `medium` / `high`. Default **high**, but warn that **high spends
  noticeably more tokens** (more finders + more adversarial verification votes).
- **Report format** — **HTML or Markdown** (always ask; no default).
- **Report location** — directory to write the report into. Default **`docs/reports/`**
  (created if missing); accept any path the user gives.
- **Gate mode** — whether to pause at the **design gate** (Step 2) and the **pre-run
  gate** (Step 3). The two are independent; default **both on (pause at both)**. Offer:
  both / only design / only pre-run / run straight through (neither).

Depth maps to workflow parameters:

| depth  | finders per type | verify votes per finding |
|--------|------------------|--------------------------|
| low    | 1                | 1 (or skip)              |
| medium | 2                | 2                        |
| high   | 3 (multi-angle)  | 3 (adversarial majority) |

## Step 2 — Design gate

Present a short, concrete plan for **this** run: chosen audit types, scope, depth and
its token implication, the finder angles per type (**fit them to what this repo
actually uses — glance at the code, do not assume**), the verification strategy, and
the profiler caveat above. **If the design gate is on, stop and wait for approval
before writing the workflow file.** If it is off, present the plan and proceed straight
to Step 3 without stopping.

## Step 3 — Write the workflow file (after design approval)

Author a workflow **tailored to this repo and the approved design** — do not paste a
fixed template. Write it to a throwaway scratch path **outside the audited repo** so it
is never committed (e.g. `${TMPDIR:-/tmp}/codebase-review-<slug>.workflow.js`), then
print the absolute path and a one-line summary.

Keep it lean — only pin down what the report depends on, let the rest fit the repo. The
workflow needs to:

- Read `args = { types, scope, angles, votes }` from the command.
- Fan out finders per audit type over the approved angles. **Finders must fully re-read
  the actual source in scope — judge from the files as they are now, never from memory
  or prior assumptions about the repo.**
- Adversarially verify each finding with `votes` skeptics (try to refute; drop on
  majority-refute), then dedup by `file:line` and rank by severity.
- Return structured JSON where each finding carries `type`, `title`, `file`, `line`,
  `severity` (critical/high/medium/low), `why`, `suggestedFix` — Step 5 reads these
  field names, so keep them stable.

Build it on the platform's own workflow primitives: `pipeline()` to find then verify
without a barrier, and schema-validated `agent()` output so findings come back
structured. Keep the script self-contained — no dependency on any external or personal
file. Nothing beyond the above needs nailing down here.

**If the pre-run gate is on, stop and wait for approval before running.** If it is off,
print the path and proceed straight to Step 4 without stopping.

## Step 4 — Run (after pre-run approval)

Invoke the Workflow tool with `{ scriptPath: "<the scratch path>" }` and
`args = { types, scope, angles, votes }` derived from the confirmed knobs and the
approved design. Let it complete.

## Step 5 — Report (Traditional Chinese)

From the workflow's returned JSON, build the report **this session** (the workflow
cannot). Save it to the confirmed report location (default **`docs/reports/`**,
`mkdir -p` if missing) as `codebase-review-<timestamp>.<html|md>` (get the timestamp
from `date '+%Y%m%d-%H%M%S'`), print the absolute path, and **do not auto-open** a browser.

- **Body in Traditional Chinese (zh-TW).** File names, paths, code identifiers, and
  `file:line` locations stay in their original form.
- Structure: 摘要(各類型 finding 數 + 嚴重度分佈) → 依稽核類型分區 → 每個 finding 一張卡:
  標題 / 位置 `file:line` / 嚴重度 / 為何是問題 / 建議修法 / 對抗驗證結論(confirmed).
- Label the perf section **靜態最佳化稽核** and restate the profiler caveat there.
- **HTML**: single self-contained file with inline CSS, severity colour-coding.
  **Markdown**: same content with headings and tables.

ARGUMENTS: $ARGUMENTS
