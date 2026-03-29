---
name: sprint-plan
description: >
  Sprint planning workflow. Creates a structured plan from the backlog with
  tasks, acceptance criteria, dependencies, and risks. Use when starting a
  new sprint, planning work, or when the user says "plan", "sprint", "what
  should we work on", or "next sprint". Always use this skill to start a
  sprint cycle — never plan without it.
---

# Sprint Planning

You are running the sprint planning phase. Your job is to produce a clear,
actionable plan that the build phase can execute autonomously.

## Step 1 — Gather context

Read these files in order. If a file doesn't exist, skip it and note its absence.

1. `tasks/backlog.md` — what needs to be done
2. `tasks/lessons.md` — what we've learned from past sprints
3. The most recent `tasks/sprints/sprint-*/retrospective.md` — what worked and didn't last time

## Step 2 — Determine sprint number

Look at existing `tasks/sprints/sprint-*` directories. The next sprint is N+1.
Create the directory: `tasks/sprints/sprint-XX/`

## Step 3 — Switch to plan mode

Now that the directory exists, activate plan mode (read-only) for the rest of
the planning phase. Do NOT write code or modify project files during planning.

## Step 4 — Produce the plan

Use the `architect` subagent to analyze the codebase and propose a plan.

The plan must follow this structure:

```markdown
# Sprint XX — [Theme or focus]

## Goal
[One sentence: what this sprint delivers]

## Type
[hotfix | normal | security] — determines which phases to run

## Tasks

### Task 1: [Name]
- **Description**: [What to do]
- **Acceptance criteria**: [How to verify it's done]
- **Files likely affected**: [List]
- **Complexity**: S / M / L
- **Dependencies**: [Other tasks or none]

### Task 2: [Name]
...

## Risks
- [Risk 1]: [Mitigation]
- [Risk 2]: [Mitigation]

## Alternatives considered
- [Alternative rejected and why]

## Assignment (duo mode)
- Engineer A: [Tasks]
- Engineer B: [Tasks]
```

## Step 5 — Self-challenge

Before presenting the plan, play devil's advocate on your own work:
- Are there hidden dependencies between tasks?
- Is the scope realistic for one sprint?
- Are we over-engineering anything?
- Are we missing anything obvious from the backlog or lessons?

Adjust the plan based on your self-challenge.

## Step 6 — Save and present

Save the plan to `tasks/sprints/sprint-XX/plan.md`.
Present it to the human for validation.

## Channel mode (remote execution)

If invoked via Channel (Telegram/Discord), adapt your output:
- Send a SHORT summary (5-10 lines max) via the Channel reply
- Full detailed output goes in the sprint file as usual
- End with: "Phase complete. `/clear` then [next phase command] when ready."
- Never continue to the next phase automatically
- Keep Channel messages concise — the human is likely on a phone

## Gotchas
- Never plan and build in the same session. The plan biases the build.
- If the backlog is empty or vague, ask the human — don't invent scope.
- Complexity estimates drift optimistic. When in doubt, size up (S→M, M→L).
- A sprint with more than 8 files modified is too big. Split it.

**STOP. Your deliverable is `plan.md`. Do NOT start building.**
The human will open a new session and invoke `/build` separately.