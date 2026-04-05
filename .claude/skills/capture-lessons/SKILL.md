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

### Lessons hygiene

Check the current size of `tasks/lessons.md`. If it exceeds ~200 entries, or
every 5th sprint, classify each entry with one of:

- **KEEP** — Still relevant, actively triggered. Leave as-is.
- **ENCODED** — The lesson is now a hook, rule, or agent instruction. Shorten
  to a one-liner referencing where it's encoded (e.g., "→ encoded in rules/backend/api.md").
- **OBSOLETE** — Context no longer applies (feature removed, stack changed). Delete.
- **STALE** — Hasn't triggered in 10+ sprints. Move to `tasks/lessons-archive.md`
  (append, don't delete — recoverable if the pattern returns).
- **PROMOTE** — Lesson is broad enough to belong in `rules/` or an agent prompt.
  Promote it there, then remove from lessons.md.

This keeps `tasks/lessons.md` actionable. A 500-entry file is not read — a
100-entry file is.

## Step 4 — Review workflow configuration

Based on the sprint findings, evaluate whether hooks, rules, or agent
prompts should be updated. Look for:

**Hooks** — patterns that need deterministic enforcement:
- A bug class found 2+ times across sprints → add a hook to prevent it
- A check that reviewers keep flagging manually → automate as hook
- Example: "tests always missing on new routes" → PostToolUse hook
  that checks for corresponding test file

**Rules** — conventions that should be encoded:
- A convention agreed upon during this sprint → add to the relevant
  rule file in `.claude/rules/`
- A new code area with specific patterns → create a scoped rule
- Example: "all API responses must use `{ data, error }`" → add to `rules/backend/api.md`

**Agent prompts** — expertise that should be remembered:
- A finding pattern the agent should watch for → update agent description
  or "what you look for" section
- A false positive the agent keeps raising → add to "what you don't do"
- Example: security-auditor keeps missing rate limiting → add to its
  attack checklist

**Skills** — workflow steps that should evolve:
- A manual step done 2+ times this sprint → create a skill
- A skill that produced poor results → note in retrospective for review

For each proposed change:
1. State what triggered it (which finding, which sprint)
2. State the specific change (which file, what to add/modify)
3. Apply the change directly

Save proposed and applied changes in the retrospective under a new
section "## Workflow updates applied".

If no changes are warranted, note "No workflow configuration changes
needed" and move on.

## Step 5 — Update documentation

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

## Step 6 — Generate the retrospective

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

## Workflow updates applied
- [hook/rule/agent/skill] — [what changed and what triggered it]
- or "No workflow configuration changes needed"
```

## Step 7 — Update the backlog

Update `tasks/backlog.md`:
- Remove completed items
- Add deferred items from review and red team
- Add any new items discovered during the sprint

## Step 8 — Notify and stop

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
workflow configuration changes (hooks/rules/agents/skills), retrospective.md,
and updated backlog.md.**
Do NOT start the next sprint. The human will open a new session and invoke
`/sprint-plan` separately.