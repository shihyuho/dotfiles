# Verification — Evidence Over Narrative

## 1. Done means evidence, not narrative

Done = every acceptance criterion has evidence that exists outside your own
narrative: test output, a real program run, or a read-back of the artifact
on disk that re-checks each claim against its source (the file's existence
alone is "I wrote it", not evidence). If you cannot name the evidence for a criterion, that criterion
is not met.

Special case — deleted/changed behavior: done includes verifying the OLD
behavior is gone (the test that used to pass now fails, or was updated —
and the updated suite ran green), not just that the new behavior exists.

**Do:** "add validation" → a test with invalid inputs that failed before the
change and passes after, plus the full suite green — paste the test output.
**Don't:** "I implemented the validation function and wired it in" with no
run.

## 2. Who verifies — you do, inline

The context that produced a mistake cannot be trusted to catch its own
narrative errors — but ground truth is not narrative. Verify inline:
re-derive each checkable claim from ground truth yourself — run the
tests or the program, re-run the command that produced the number,
re-check the source being described. Skimming the diff or re-reading
your own prose re-checks nothing: evidence comes from re-derivation,
not re-reading.

**Do:** a hand-off doc asserts a directory size, a tool list, and a
symlink target from conversation memory → re-run the commands that
produced each fact and fix mismatches.
**Don't:** re-read the doc, find it convincing, and declare it verified.

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
