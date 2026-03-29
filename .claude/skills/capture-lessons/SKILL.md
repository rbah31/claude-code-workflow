---
name: capture-lessons
description: >
  Ship and capture lessons workflow. Creates the PR, updates lessons learned,
  updates documentation, generates the sprint retrospective, and updates the
  backlog. Use at the end of a sprint cycle, or when the user says "ship",
  "capture", "lessons", "retro", "retrospective", "wrap up", or "done with
  this sprint". Also use when the user says "we're done" after fixes.
  Always use this skill as the last phase of a sprint.
---

# Ship & Capture Phase

You are running the final phase of the sprint. Your job is to close the loop:
ship the code, capture what was learned, and prepare for the next sprint.

## Step 1 — Load context

First, determine the current sprint: look at `tasks/sprints/` directories and
find the most recent one (highest number). Call it sprint-XX below.

Read all sprint artifacts:

1. `tasks/sprints/sprint-XX/plan.md` — what was planned
2. `tasks/sprints/sprint-XX/build-output.md` — what was built
3. `tasks/sprints/sprint-XX/review-output.md` — what was found in review
4. `tasks/sprints/sprint-XX/fix-output.md` — what was fixed
5. `tasks/sprints/sprint-XX/redteam-output.md` — security findings (if exists, skip if not)
6. `tasks/lessons.md` — existing lessons

If any artifact is missing (e.g., no red-team output for a normal sprint),
note its absence and continue with what's available.

## Step 2 — Create the PR

Prepare a pull request description based on the sprint artifacts:

```markdown
## Sprint XX — [Theme]

### What changed
[Summary of changes from build-output]

### Key decisions
[Technical decisions and their rationale]

### Testing
[Tests added, coverage changes]

### Security
[Security considerations, red team findings if applicable]

### Review notes
[Anything the PR reviewer should know]
```

If git is configured, create the PR. Otherwise, save the PR description to
`tasks/sprints/sprint-XX/pr-description.md` for the human to use.

## Step 3 — Update lessons learned

Add new entries to `tasks/lessons.md` based on what happened this sprint.

Each lesson follows this format:

```markdown
### [Date] — [Author or "Claude"] — Sprint XX
**Context**: [What was happening]
**What went wrong (or right)**: [What happened]
**Lesson**: [The takeaway — a rule to follow going forward]
```

Look for lessons in:
- Review findings that were critical (why weren't they caught earlier?)
- Fix output (any recurring patterns?)
- Red team findings (any systemic security issues?)
- Build blockers (what slowed us down?)
- Things that went well (what should we keep doing?)

## Step 4 — Update documentation

Check if the sprint's changes require documentation updates:

1. **README.md** — Do setup instructions still work? Are new features
   documented? Are removed features still listed?

2. **Architecture/API docs** — If the sprint added or changed endpoints,
   commands, data models, or infrastructure, update the relevant docs.

3. **CLAUDE.md** — If the sprint changed the stack, conventions, or
   architecture, update it. This should be rare.

For each doc update:
- Make the minimal change that keeps the doc accurate.
- Don't rewrite entire docs — update only what changed this sprint.
- If a doc doesn't exist yet but should (e.g., API reference after adding
  5+ endpoints), create a skeleton and add "flesh out docs" to the backlog.

## Step 5 — Generate the retrospective

Save to `tasks/sprints/sprint-XX/retrospective.md`:

```markdown
# Retrospective — Sprint XX

## What went well
- [Thing that worked]
- ...

## What didn't go well
- [Thing that didn't work]
- ...

## What to improve
- [Actionable improvement for next sprint]
- ...

## Metrics
- Tasks planned: X
- Tasks completed: X
- Critical issues found in review: X
- Security vulnerabilities found: X (if red team was run)
- Lessons captured: X

## Documentation updated
- [file] — [what was updated and why]
- or "No doc changes needed this sprint"
```

## Step 6 — Update the backlog

Update `tasks/backlog.md`:
- Remove completed items
- Add deferred items from review and red team
- Add any new items discovered during the sprint

## Step 7 — Notify and stop

Signal to the human:
"Sprint XX complete. PR ready, lessons captured, docs updated, retro generated,
backlog updated. Ready to merge and start the next sprint with `/sprint-plan`."

## Channel mode (remote execution)

If invoked via Channel (Telegram/Discord), adapt your output:
- Send a SHORT summary (5-10 lines max) via the Channel reply
- Full detailed output goes in the sprint file as usual
- End with: "Phase complete. `/clear` then [next phase command] when ready."
- Never continue to the next phase automatically
- Keep Channel messages concise — the human is likely on a phone

## Gotchas
- Don't update docs you haven't read. Read the current doc first, then make minimal changes.
- Lessons should be rules, not stories. "Always grep all occurrences" not "We had a bug where..."
- Remove completed backlog items — don't comment them out. History is in git.
- If a lesson applies to a specific skill, add it as a gotcha in that skill too.

## Memory
After completing the retrospective, append a summary to `tasks/sprint-history.log`:
```
[YYYY-MM-DD] Sprint XX — Type: [normal/security/hotfix] — X tasks planned, X completed — X critical findings — X lessons captured
```
This log gives a quick overview of project velocity across sprints.

**STOP. Your deliverables are: PR description, updated lessons.md, updated docs,
retrospective.md, and updated backlog.md.**
Do NOT start the next sprint. The human will open a new session and invoke
`/sprint-plan` separately.