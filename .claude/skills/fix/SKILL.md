---
name: fix
description: >
  Fix phase workflow. Fixes issues identified during code review, based on the
  triaged review output. Use after a review phase is complete and the human has
  triaged the findings, or when the user says "fix", "fix the issues",
  "address review feedback", or "apply fixes". Also use when the user says
  "fix these" after reviewing findings. Always use this skill after /review.
---

# Fix Phase

You are running the fix phase. Your job is to fix all issues the human marked
as "fix" in the review output — efficiently and correctly.

## Step 1 — Load context

Read the triaged review output: `tasks/sprints/sprint-*/review-output.md`.
Read `tasks/lessons.md` — avoid repeating past fix mistakes.

Identify all items marked as "fix" (or "critical" / "major" that weren't
explicitly deferred).

## Step 2 — Fix issues

For each issue to fix:

1. **Understand the issue** — read the finding, the file, and the context.
2. **Plan if complex** — if the fix touches 3+ files, switch to plan mode
   first to design the approach.
3. **Implement the fix** — make the minimal change that resolves the issue.
   Don't refactor unrelated code.
4. **Run tests** — verify the fix works and doesn't break anything else.
5. **Document** — note what you did in the fix output.

If a fix introduces a new issue or breaks something: stop, assess, and fix the
regression before moving on.

### Guard-fou: 3 failed attempts

If three attempted fixes for the same finding all fail (tests still break or
the issue persists after 3 tries):

1. **STOP fixing this issue.**
2. Mark it as "needs architectural review" in the fix output.
3. Move to the next issue.
4. The human will defer it to the next sprint where the `architect` agent
   can re-evaluate the approach.

Do not keep trying variations. Three failures means the fix is not trivial —
it needs a design rethink, not more attempts.

## Step 3 — Produce the fix output

When all fixes are done, save:

`tasks/sprints/sprint-XX/fix-output.md`

```markdown
# Fix Output — Sprint XX

## Fixes applied

### [Issue description from review]
- **File(s)**: [paths]
- **Fix**: [What was changed and why]
- **Verified**: Tests pass ✅ / ❌

### [Next issue]
...

## Issues deferred
- [Issue]: [Reason for deferral] — Added to backlog: yes/no

## Issues needing architectural review
- [Issue]: Failed after 3 attempts — [what was tried and why it failed]

## Status
All fixes verified: ✅ / ❌
All tests passing: ✅ / ❌
```

## Step 4 — Notify and stop

Signal to the human: "Fixes complete, ready for `/red-team` (security sprint)
or `/capture-lessons` (normal sprint)."

## Channel mode (remote execution)

If invoked via Channel (Telegram/Discord), adapt your output:
- Send a SHORT summary (5-10 lines max) via the Channel reply
- Full detailed output goes in the sprint file as usual
- End with: "Phase complete. `/clear` then [next phase command] when ready."
- Never continue to the next phase automatically
- Keep Channel messages concise — the human is likely on a phone

## Gotchas
- Fix items marked "fix". Suggestions and deferred items stay deferred — they belong in the backlog or the next sprint, not this fix phase.
- Run tests after each fix, not just at the end. One fix can break another.
- Stop after the 3rd touch on the same file — the design is wrong, not the code. Mark for architectural review.
- Minimal change only. Refactoring during fix expands scope and risks new bugs.

**STOP. Your deliverable is `fix-output.md`.**
The human will open a new session and invoke the next phase separately.