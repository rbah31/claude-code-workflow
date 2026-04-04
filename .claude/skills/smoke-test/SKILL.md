---
name: smoke-test
description: >
  Post-sprint validation. Verifies the application works as expected
  after a sprint completes. Use after any sprint or deployment, or
  when the user says "smoke test", "verify it works", "test the app",
  "does it still work", "regression check", "post-deploy check", or
  "sanity check". Invoked by SP-QA during post-sprint review.
---

# Smoke Test

You are running a post-sprint validation. Your job is to verify the
application still works correctly after recent changes.

## Step 1 — Understand what changed

Read the latest sprint plan to understand what was modified:
`tasks/sprints/sprint-*/plan.md` (latest).

If `tasks/sprints/sprint-*/build-output.md` exists, read it for the
list of modified files.

## Step 2 — Run the test suite

Detect the test runner:
- If `package.json` exists → `npm test` or check scripts
- If `pytest.ini`, `setup.cfg`, `pyproject.toml` → `pytest`
- If `Makefile` with test target → `make test`
- If `Cargo.toml` → `cargo test`
- If none found → report "no test runner detected"

Run the full test suite and capture results.

## Step 3 — Compare with baseline

Check `tasks/lessons.md` or previous sprint outputs for baseline test counts.
If a baseline exists, compare:
- Are there fewer tests now? (tests removed?)
- Are there new failures?

## Step 4 — Health checks

If the project has identifiable health endpoints or CLI commands:
- Web app: check if key endpoints respond (look for routes in code)
- CLI: verify key commands run without error
- API: check health/status endpoint if it exists

If none are identifiable, skip this step and note it.

## Step 5 — Check for common regressions

- Imports that break (look for import errors in test output)
- Config files that changed (diff against previous sprint)
- Dependency conflicts (check lock file changes)

## Step 6 — Produce output

Save to `tasks/sprints/sprint-XX/smoke-test-output.md`:

```markdown
# Smoke Test — Sprint [XX]

## Test suite
- Runner: [pytest/npm/etc.]
- Total tests: [count]
- Passed: [count]
- Failed: [count]
- Baseline (last sprint): [count if known]

## Regression check
- New test failures: [list or "none"]
- Missing tests (removed?): [list or "none"]

## Health checks
- [Endpoint/command]: [status]

## Verdict
[PASS / FAIL / PASS WITH WARNINGS]
[If fail: what specifically failed and recommended action]
```

## Channel mode (remote execution)

If invoked via Channel (Telegram/Discord), adapt your output:
- Send a SHORT summary (5-10 lines max) via the Channel reply
- Full output goes in the sprint file as usual
- Include the verdict prominently
- Keep Channel messages concise — the human is likely on a phone

## Gotchas
- Don't skip the test suite. Running tests is the minimum bar.
- If tests take too long (>5 min), note the duration as a concern.
- A passing test suite doesn't mean the app works. Health checks catch what unit tests miss.
- If no test runner is detected, flag this as a major concern — the project has no automated tests.

**STOP. Your deliverable is `smoke-test-output.md`.**
Do NOT fix any issues found. Report them for the next sprint or /fix.
