---
name: build
description: >
  Build phase workflow. Implements the sprint plan by writing code, running
  tests, and producing a build output. Use after sprint planning is complete,
  or when the user says "build", "implement", "code this", "start building",
  or "let's build". Also use when the user says "let's go" after validating
  a plan. Always use this skill after /sprint-plan.
---

# Build Phase

You are running the build phase. Your job is to implement every task in the
sprint plan — efficiently, correctly, and with tests.

## Step 1 — Load context

Read the sprint plan: find the latest `tasks/sprints/sprint-*/plan.md`.
Read `tasks/lessons.md` — avoid repeating past mistakes.

If `design-system/MASTER.md` exists and any task modifies frontend/landing
files, read it before implementing visual changes.

## Step 2 — Implement tasks

For each task in the plan:

1. **Assess complexity** — if it touches 3+ files, switch to plan mode first
   to design the approach before writing code.
2. **Implement** — write the code, following project conventions from CLAUDE.md
   and applicable rules.
3. **Test** — run the test suite after each task. If tests fail, fix before
   moving to the next task.
4. **Save progress** — after each completed task, update
   `tasks/sprints/sprint-XX/build-output.md` with what's done. This is your
   checkpoint — if context is lost, you resume from here.

If Agent Teams is available and tasks are parallelizable (e.g., independent
frontend + backend + tests), parallelize them. Otherwise, sequential is fine.

## Step 3 — Monitor context

Check your context usage periodically.

- If approaching the limit: use `/compact` (NOT clear context).
- `/compact` preserves your task progress. Clear context does NOT.
- **If context was compacted or cleared**: re-read `tasks/sprints/sprint-XX/plan.md`
  and your partial `build-output.md` before continuing. These files are your
  recovery mechanism — always save progress incrementally.
- After each completed task, update `build-output.md` with what's done.
  This way, if context is lost, you can resume from the last saved state.

If the build would exceed ~60% of context, signal to the human that a session
split is recommended. Save progress to `build-output.md` and stop.

## Step 4 — Produce the build output

When all tasks are done, finalize:

`tasks/sprints/sprint-XX/build-output.md`

```markdown
# Build Output — Sprint XX

## Tasks completed

### Task 1: [Name]
- **Files modified**: [list]
- **What was done**: [description]
- **Tests**: passing ✅ / failing ❌

### Task 2: [Name]
...

## Tasks deferred
- [Task]: [Reason for deferral]

## Notes
[Anything the reviewer should know — decisions made, trade-offs, concerns]

## Status
All tasks completed: ✅ / ❌
All tests passing: ✅ / ❌
```

## Step 5 — Notify and stop

Signal to the human: "Build complete, ready for `/review`."

## Channel mode (remote execution)

If invoked via Channel (Telegram/Discord), adapt your output:
- Send a SHORT summary (5-10 lines max) via the Channel reply
- Full detailed output goes in the sprint file as usual
- End with: "Phase complete. `/clear` then [next phase command] when ready."
- Never continue to the next phase automatically
- Keep Channel messages concise — the human is likely on a phone

## Gotchas
- Never use "clear context" mid-build. Use /compact — it preserves progress.
- Save build-output.md after EACH task, not just at the end. It's your checkpoint.
- If a hardcoded value exists somewhere (count, price, URL), grep for ALL occurrences before changing one.
- Don't refactor unrelated code during a build. One sprint scope, nothing else.
- If design-system/MASTER.md exists and you're touching frontend, read it first.

## Memory
After completing the build, append a one-line entry to `tasks/build-history.log`:
```
[YYYY-MM-DD] Sprint XX — X tasks, X files modified, X tests — [clean/issues]
```
This log helps future sprint planning estimate velocity and spot trends.

**STOP. Your deliverable is `build-output.md`.**
The human will open a new session and invoke `/review` separately.
Do NOT start reviewing your own code.