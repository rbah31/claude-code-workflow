---
name: review
description: >
  Code review workflow. Reviews the build output for quality, conventions,
  performance, security, and test coverage. Use after a build phase is
  complete, or when the user says "review", "check the code", "PR review",
  "quality check", or "is this good". Also use when the user wants a second
  opinion on code that was just written. Always use this skill after /build.
---

# Review Phase

You are running the code review phase. Your job is to find issues the builder
missed — you are a fresh pair of eyes.

## Step 1 — Load context

Read the build output: find the latest `tasks/sprints/sprint-*/build-output.md`.
Read `tasks/lessons.md` — check for recurring issues to watch for.

Do NOT read the sprint plan in detail. You want a fresh perspective on the code,
not the builder's reasoning.

## Step 2 — Run the review

### Core reviewers (always invoked)

Invoke these subagents on the modified files from the build output:

1. **`code-reviewer`** — quality, conventions, readability, maintainability
2. **`qa-tester`** — test coverage, missing edge cases, test quality

### Conditional reviewers

Check the files modified in `build-output.md`. Invoke additional reviewers
based on what was changed:

- **Files matching** `.github/workflows/`, `Dockerfile`, `docker-compose`,
  `infrastructure/`, `deploy`, `Makefile`, `scripts/deploy`, `samconfig`,
  `template.yaml`, `terraform/`, `*.tf`, `CI`, `CD`:
  → Also invoke `ops-engineer` for infrastructure review

- **Files matching** `billing`, `stripe`, `pricing`, `plan`, `upgrade`,
  `subscription`, `checkout`, `webhook`:
  → Also invoke `billing-auditor` for business logic review (if agent exists)

- **Files matching** `landing/`, `src/pages/`, `src/components/`, `i18n`,
  `embeds`, `cogs/`, `src/bot/`:
  → Also invoke `product-reviewer` for UX review (if agent exists)

If an optional agent doesn't exist in `.claude/agents/`, skip it silently.

### If Agent Teams is available

Parallelize all reviewers (core + conditional) as teammates.
If Agent Teams is not available: run subagents sequentially. Same result.

## Step 3 — Consolidate findings

Merge all findings into a single review output, classified by severity:

`tasks/sprints/sprint-XX/review-output.md`

```markdown
# Review Output — Sprint XX

## Summary
[1-2 sentences: overall quality assessment]

## Findings

### Critical (must fix before merge)
- **[file:line]** — [Reviewer] — [Description] — Suggestion: [fix]

### Major (should fix)
- **[file:line]** — [Reviewer] — [Description] — Suggestion: [fix]

### Minor (nice to fix)
- **[file:line]** — [Reviewer] — [Description]

### Suggestions (optional improvements)
- [Description]

## Test coverage assessment
[Are tests sufficient? What edge cases are missing?]

## Action items
- [ ] [Issue 1] — Priority: critical
- [ ] [Issue 2] — Priority: major
- ...
```

## Step 4 — Present for triage

Present the review output to the human.

The human will triage: mark each issue as "fix", "defer", or "ignore".
Wait for human validation before proceeding to `/fix`.

Do NOT fix anything yourself. Your job is to find issues, not fix them.

## Channel mode (remote execution)

If invoked via Channel (Telegram/Discord), adapt your output:
- Send a SHORT summary (5-10 lines max) via the Channel reply
- Full detailed output goes in the sprint file as usual
- End with: "Phase complete. `/clear` then [next phase command] when ready."
- Never continue to the next phase automatically
- Keep Channel messages concise — the human is likely on a phone

## Gotchas
- Don't read the sprint plan in detail. Fresh eyes find more bugs than informed eyes.
- Check cross-surface consistency: if a number appears in code, landing, i18n, and bot — they must all match.
- The most dangerous findings look like "the code is correct but the behavior is wrong" — focus on what the user sees, not just what the code says.
- If an optional agent doesn't exist, skip it silently — don't error.

**STOP. Your deliverable is `review-output.md`.**
The human will open a new session and invoke `/fix` separately.