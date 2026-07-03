# Verification — Evidence Over Narrative

Assumes each task already carries success criteria; how to define them is
out of scope here.

## 1. Done means evidence, not narrative

Done = every acceptance criterion has evidence that exists outside your own
narrative: test output, a real program run, or a fresh-context read-back of
the artifact on disk (the file's existence alone is "I wrote it", not
evidence). If you cannot name the evidence for a criterion, that criterion
is not met. "I wrote it" is not "it works."

Special case — deleted/changed behavior: done includes verifying the OLD
behavior is gone (the test that used to pass now fails or was updated), not
just that the new behavior exists.

**Do:** "add validation" → a test with invalid inputs that failed before the
change and passes after, plus the full suite green — paste the test output.
**Don't:** "I implemented the validation function and wired it in" with no
run. Code that has never executed is a draft, not a deliverable.

## 2. Who verifies

The context that produced a mistake cannot be trusted to catch its own
narrative errors. Who runs the check depends on where the risk lives:

- **Code changes** → the objective output is the evidence: run the tests or
  the actual program — running them yourself inline satisfies this. Reading
  the diff is not verification.
- **File deliverables the user will directly consume** (reports, configs,
  docs) → a fresh-context agent reads the file from disk and checks it
  against the stated acceptance criteria. Scratch and intermediate files
  are exempt.
- **High-risk judgment calls** (irreversible, user-facing, architectural) →
  either a second opinion from a fresh agent told to *refute* the
  conclusion, or 2–3 independent candidates and a fresh judge to pick.

When verification is delegated to a fresh context, two rules keep it from
becoming theater:

- The verifier gets the acceptance criteria only — **not** the reasoning
  that produced the work, so it cannot inherit the author's blind spot.
- If you did not act on the verifier's output, you did not verify. Citing
  the evidence (line numbers, command output) is part of declaring done.

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
