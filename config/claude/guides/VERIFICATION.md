# Verification — Evidence Over Narrative

## 1. Done means evidence, not narrative

Done = every acceptance criterion has evidence that exists outside your own
narrative: test output, a real program run, or a fresh-context read-back of
the artifact on disk (the file's existence alone is "I wrote it", not
evidence). If you cannot name the evidence for a criterion, that criterion
is not met.

Special case — deleted/changed behavior: done includes verifying the OLD
behavior is gone (the test that used to pass now fails, or was updated —
and the updated suite ran green), not just that the new behavior exists.

**Do:** "add validation" → a test with invalid inputs that failed before the
change and passes after, plus the full suite green — paste the test output.
**Don't:** "I implemented the validation function and wired it in" with no
run.

## 2. Who verifies — match the check to the error type

The context that produced a mistake cannot be trusted to catch its own
narrative errors — but ground truth is not narrative. Pick the cheapest
check that catches each error type at risk; if the classification is
arguable, the ambiguity is itself a judgment risk — take the stronger
check. A fresh context is a tool for judgment errors, not a toll paid
per artifact.

- **Objectively checkable claims** — code behavior, and hard facts
  carried into an artifact from memory or earlier context (numbers,
  paths, names, IDs) → re-derive them from ground truth yourself, inline:
  run the tests or the program, re-run the command that produced the
  number, re-check the source being described. Reading the diff (or
  re-reading your own prose) is not verification.
- **Interpretive quality** — does the artifact satisfy its acceptance
  criteria; will the reader draw the right conclusion → a fresh-context
  read-back from disk against the acceptance criteria, because the
  author's judgment of their own work inherits the author's blind spots.
  Reserve this for deliverables acted on with no downstream gate you can
  name — the consumer reading it is consumption, not a gate (a report
  the user decides from); skip what still has one (a scratch file only
  you revisit, a draft going into an agreed review round).
- **High-risk judgment calls** (hard to reverse, or architecturally
  load-bearing — mere user visibility does not qualify) → either a
  second opinion from a fresh context told to *refute* the conclusion,
  or 2–3 independent candidates and a fresh judge to pick.

When verification is delegated to a fresh context, two rules keep it from
becoming theater:

- The verifier gets the acceptance criteria only — **not** the reasoning
  that produced the work, so it cannot inherit the author's blind spot.
- If you did not act on the verifier's output, you did not verify. Citing
  the evidence (line numbers, command output) is part of declaring done.

**Do:** a hand-off doc asserts a directory size, a tool list, and a
symlink target from conversation memory → re-run the commands that
produced each fact and fix mismatches; no delegation needed.
**Don't:** delegate a read-back to bless numbers a command re-derives.

## 3. Wrong-direction signals — change path instead of retrying

Any of these means the approach is wrong; retrying it harder makes it worse:

- **Whack-a-mole:** fixing one place breaks another, twice.
- **Growing fix:** attempt 1 was 3 lines, attempt 2 is 30, attempt 3 wants
  to touch 10 files. Effort should shrink as understanding grows.
- **Test bending:** you are about to weaken/mock/skip a test so it passes.
  The test is the spec; bending it means the code is wrong or the design is.
- **Special-case stacking:** each new input class needs another `if`.
- **Fighting the framework:** you need undocumented internals or
  monkey-patching to proceed.

On a signal: stop, write down (a) what you now know that you didn't at the
start, (b) the smallest alternative approach — then take it, or escalate
(a stronger model, or bring the write-up to the user).

**Do:** passing the test requires mocking three internal functions → the
seam is in the wrong place; redesign the seam, don't add the mocks.
**Don't:** an unrelated flaky test failed after your one-line typo fix →
not a direction signal; rerun to confirm flakiness and proceed.
