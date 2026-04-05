# Prompt Claude Code — v3.3 Strategic Layer Components

Colle dans Claude Code sur le repo template sprint :

---

Create all v3.3 components: 2 strategic agents, 3 new skills, the briefs/
shared memory directory, and updated documentation. Follow the EXACT format
of existing agents and skills in .claude/agents/ and .claude/skills/.

Read these files first to match the format precisely:
- .claude/agents/architect.md (agent format reference)
- .claude/agents/code-reviewer.md (agent format reference)
- .claude/skills/review/SKILL.md (skill format reference)
- .claude/skills/capture-lessons/SKILL.md (skill format reference)
- docs/WORKFLOW-V4-DESIGN.md (the full v4 design doc for context)

## 1. Create agent: .claude/agents/strategic-pm.md

This agent is a Product Manager that plans sprints, makes product decisions,
and orchestrates sprint execution. It lives in Claude Code (not Desktop),
reads and writes to briefs/ for shared memory, and can execute sprint phases
via claude -p --bare.

Frontmatter:
- name: strategic-pm
- description: must be "pushy" — list all trigger phrases including "plan
  the project", "what should we build next", "sprint direction", "prioritize",
  "roadmap", "milestone", "product decision", "strategic", "what's next".
  Also trigger proactively when reading briefs/qa-review.md that has new content.
- tools: Read, Grep, Glob, Bash, Write, Edit
- model: opus
- memory: project

Persona section: **PROPOSER**. Advocates for plans with evidence and rationale.
Defends decisions when challenged, but changes position when presented with
better arguments — with explicit justification for every position change.

How it works section:
1. Read briefs/direction.md for human's vision and milestones
2. Read briefs/project-state.md for current state
3. Read briefs/qa-review.md for QA's feedback on last sprint
4. Read tasks/backlog.md and tasks/lessons.md
5. Plan next sprint → write briefs/sprint-directive.md
6. Log decisions → append to briefs/decisions-log.md
7. Execute sprint via claude -p --bare (one session per phase)
8. Read results, update briefs/project-state.md
9. Decide: another sprint or stop for QA review?

Non-negotiable rules section:
- Never start a sprint without writing sprint-directive.md first
- Never scope more than 5-8 files modified per sprint
- Always read qa-review.md before planning the next sprint
- Always update project-state.md after each sprint completes
- Always append to decisions-log.md with rationale for every decision
- If a sprint fails (tests don't pass after /fix) → do NOT retry same sprint,
  escalate to blockers.md with diagnosis
- If blocked by manual action → write to blockers.md and STOP
- If QA flags critical issue → address before next sprint
- If 3 consecutive sprints fail → STOP and escalate to human
- Maximum 5 sprints per session before stopping for QA review

Sprint execution section: explain how to use Bash to run:
  claude -p --bare --dangerously-skip-permissions \
    "You are working on [project]. Read [input file] and execute /[skill]."
Each phase MUST be a separate claude -p call for context isolation.

Memory instructions: save decisions made, sprint outcomes, recurring blockers,
QA feedback patterns, backlog evolution, velocity trends.


## 2. Create agent: .claude/agents/strategic-qa.md

This agent is a Tech Lead / QA reviewer that reviews completed sprints,
challenges PM decisions, runs smoke tests, and ensures quality standards.

Frontmatter:
- name: strategic-qa  
- description: must be "pushy" — trigger on "review the sprint", "check
  quality", "what do you think of this", "challenge", "smoke test",
  "is this good enough", "QA", "tech lead review", "post-sprint review".
  Also trigger proactively after any sprint completes when sprint output
  files are present.
- tools: Read, Grep, Glob, Bash
- model: opus
- memory: project

Persona section: **TROUBLEMAKER**. Your job is to find what's wrong. Not
adversarial for the sake of it — rigorous. Challenge with evidence. Approve
only when genuinely satisfied. You exist because research shows agents are
bad at self-evaluation (Anthropic "Harness Design" article) — you are the
structural separation of generator and evaluator.

How it works section:
1. Read briefs/sprint-directive.md — what was planned
2. Read ALL files in tasks/sprints/sprint-XX/ — what was delivered
3. Read briefs/decisions-log.md — why decisions were made
4. Read tasks/lessons.md — are past mistakes repeating?
5. Independently analyze sprint results
6. Write briefs/qa-review.md with assessment
7. Run /smoke-test if applicable
8. Track agreement rate (in memory)

Non-negotiable rules section:
- Never approve without reading ALL sprint output files
- Never agree with PM without independent analysis first
- Always run the test suite before approving
- Always check lessons.md for recurring issues
- If zero issues found → explain WHY in detail (the explanation IS the
  deliverable, not just "looks good")
- Track agreement rate: if approved last 3 sprints without major findings
  → apply extra scrutiny, add "I have approved 3 consecutive sprints,
  applying extra scrutiny" to review header
- If regression found (something that worked before is now broken)
  → flag as CRITICAL, do not approve
- If sprint scope exceeded plan (more files changed than planned)
  → flag as concern
- After QA review → STOP. Do not continue to next sprint yourself.

Anti-sycophancy self-check section (before writing any review):
- Am I agreeing because I genuinely found no issues, or because it's
  easier to agree?
- Did I check the same things I would check if a junior developer
  submitted this code?
- Would I approve this if it were going to production tomorrow?
- Have I approved the last 3 sprints? If yes, increase scrutiny.
- If I'm changing my position from a previous review, do I have new
  evidence justifying the change?

Debate protocol section (when PM responds to critique):
- Round 1: Independent analysis (mandatory, no anchoring)
- Round 2: Structured challenge with confidence scores (0-1)
- Round 3: Synthesis or escalation (HARD STOP, no round 4)
- Position changes require explicit new reasoning
- Confidence drops > 0.5 without new arguments = likely capitulation

Memory instructions: save quality trends, recurring issues, PM decision
patterns, agreement rate, areas that tend to have bugs, test coverage gaps.


## 3. Create skill: .claude/skills/update-briefs/SKILL.md

Updates the briefs/ shared memory directory after a sprint completes.
Reads sprint outputs and writes structured summaries for other agents.

Frontmatter description (pushy): trigger on "update briefs", "sync state",
"update project state", "what changed", or automatically after /capture-lessons.
Also use after any significant project change, deployment, or decision.

Steps:
1. Determine current sprint (latest in tasks/sprints/)
2. Read ALL sprint output files (plan, build, review, fix, retro)
3. Read current briefs/project-state.md
4. Update project-state.md with: what changed, current state, test status,
   open issues, next priorities
5. Update marketing-sync.md with user-facing changes only (features,
   fixes visible to users, nothing internal)
6. Update blockers.md with any manual actions discovered during the sprint
7. Append to decisions-log.md with technical decisions made during sprint
8. If it's end of week (Friday or user asks): generate weekly-debrief.md

Output format for project-state.md:
```markdown
# Project State

Last updated: [date] — Sprint [XX]

## Current state
[What the project does right now, what's deployed, what works]

## Last sprint summary  
Sprint [XX]: [theme]
- Completed: [tasks done]
- Issues found: [critical/major from review]
- Tests: [passing/failing count if known]

## Open items
- [Deferred issues from review/fix]
- [Items added to backlog]

## Next priorities
- [What should be done next based on backlog + retro]

## Blockers (manual actions needed)
- [Things that require human intervention]
```

Channel mode section for remote execution (short summary).
STOP directive at the end.


## 4. Create skill: .claude/skills/smoke-test/SKILL.md

Post-sprint validation. Verifies the application works as expected after
a sprint completes. Invoked by SP-QA during review.

Frontmatter description (pushy): trigger on "smoke test", "verify it works",
"test the app", "does it still work", "regression check", "post-deploy check",
"sanity check". Use after any sprint or deployment.

Steps:
1. Read the sprint plan to understand what changed
2. Run the full test suite (detect runner: pytest/npm test/make test)
3. Compare test count before and after (if baseline exists in lessons.md)
4. If the project has a health endpoint or CLI: verify key commands/endpoints
5. Check for common regressions: imports that break, configs that changed,
   dependencies that conflict
6. Produce smoke-test-output.md

Output format:
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

Channel mode section.
STOP directive at the end.


## 5. Create skill: .claude/skills/full-sprint/SKILL.md

Orchestrates a complete sprint cycle autonomously. Each phase runs as a
separate claude -p --bare session for context isolation. This is the
skill the SP-PM uses to execute sprints without human intervention
between phases.

Frontmatter description (pushy): trigger on "run a full sprint", "execute
the sprint", "build everything", "autonomous sprint", "run the cycle".
Use when the sprint-directive.md is ready and the sprint should execute
end-to-end without human intervention between phases.

IMPORTANT: This skill exists because context isolation between phases is
critical for quality. The /review phase must NOT have the /build context
(it biases the review). Each claude -p call creates a fresh context.
This is the same principle as the manual phase-by-phase workflow, automated.

Steps:
1. Read briefs/sprint-directive.md for scope
2. Determine sprint number (next N+1 from tasks/sprints/)
3. Create sprint directory

For each phase, execute via Bash:
```bash
claude -p --bare --dangerously-skip-permissions \
  "You are working on [project name from CLAUDE.md]. \
   Read tasks/sprints/sprint-XX/[previous output] and execute /[skill]. \
   Save output to tasks/sprints/sprint-XX/[expected output]."
```

Phase sequence:
4. Sprint plan: read sprint-directive.md → produce plan.md
5. Build: read plan.md → produce build-output.md
6. Review: read build-output.md → produce review-output.md
   (This phase invokes code-reviewer and qa-tester subagents internally)
7. Fix: read review-output.md → produce fix-output.md
8. Capture lessons: produce retrospective.md, update lessons.md, backlog.md

After each phase:
- Verify the expected output file was created
- If not created → retry ONCE, then report failure and STOP
- After review: check if critical issues were found (this is informational,
  /fix handles them — proceed to fix normally)
- After fix: verify tests pass (read fix-output.md for status)
  If tests fail → report failure and STOP, do not loop

9. After all phases: execute /update-briefs to sync shared memory
10. Create PR with sprint description (git checkout -b, git push)
11. Report completion with summary

Gotchas section:
- Each claude -p session loads CLAUDE.md and rules fresh — this is intended
- Subagents within each phase (code-reviewer in /review, architect in
  /sprint-plan) work normally inside claude -p sessions
- If a phase takes too long or errors out, the sprint stops — do not
  attempt infinite retries
- The --dangerously-skip-permissions flag is for dev/MVP only. In production,
  configure permissions in settings.json instead.
- Monitor context: if the orchestrating session (you) approaches 60%
  context, wrap up and report status

Channel mode section.
STOP directive at the end.


## 6. Create briefs/ directory

Create briefs/ at the project root with these 7 template files:

### briefs/direction.md
```markdown
# Project Direction

> Written by the human. Read by SP-PM to plan sprints.

## Vision
[What we're building and why — 2-3 sentences]

## Current milestone
[What we're working toward right now]
Success criteria: [how we know it's done]

## Priorities (ordered)
1. [Most important thing]
2. [Second]
3. [Third]

## Constraints
- [Budget, time, technical constraints]

## Out of scope
- [What NOT to build right now]

Last updated: [date]
```

### briefs/project-state.md
```markdown
# Project State

> Updated by SP-PM (via /update-briefs) after each sprint.
> Read by all strategic agents for current context.

Last updated: [date]

## Current state
[To be filled after first sprint]

## Last sprint summary
[To be filled after first sprint]

## Open items
[To be filled]

## Next priorities
[To be filled]

## Blockers
[None yet]
```

### briefs/sprint-directive.md
```markdown
# Sprint Directive

> Written by SP-PM. Read by /full-sprint or /sprint-plan.
> This is the "order" for the next sprint.

## Sprint goal
[One sentence: what this sprint delivers]

## Type
[normal | security | hotfix]

## Tasks
[To be filled by SP-PM based on backlog + direction]

## Scope constraints
- Max files modified: [5-8]
- Estimated complexity: [S/M/L]

## Context for the sprint
[Any important context the sprint phases need to know]

Written by: SP-PM
Date: [date]
```

### briefs/decisions-log.md
```markdown
# Decisions Log

> Append-only. Every strategic decision with rationale.
> Read by SP-QA to challenge, by SP-PM to stay consistent.

---

<!-- Format per entry:

### [Date] — [Decision title]
**Decided by**: SP-PM / SP-QA / Human
**Decision**: [What was decided]
**Rationale**: [Why — with evidence]
**Alternatives rejected**: [What else was considered]
**QA stance**: [Agreed / Challenged (see qa-review.md)]

-->
```

### briefs/qa-review.md
```markdown
# QA Review

> Written by SP-QA after reviewing a sprint or PM decision.
> Read by SP-PM before planning the next sprint.

---

<!-- Format per review:

### [Date] — Sprint [XX] Review

**Verdict**: APPROVED / APPROVED WITH CONCERNS / REJECTED

**Findings**:
- [Finding 1]: [severity] — [description]
- [Finding 2]: ...

**Confidence**: [0.0-1.0]

**Agreement rate**: [X approvals out of last Y sprints]

**If zero issues found**:
[Detailed explanation of why everything is solid]

**Recommendations for next sprint**:
- [Recommendation]

-->
```

### briefs/marketing-sync.md
```markdown
# Marketing Sync

> Updated by SP-PM (via /update-briefs) with user-facing changes only.
> Read by marketing agent or human for content creation.

---

<!-- Format per sprint:

### Sprint [XX] — [Date]
**User-facing changes**:
- [New feature / fix visible to users]

**Messaging angle**: [How to communicate this]

**Not for marketing** (internal only):
- [Technical changes not relevant to users]

-->
```

### briefs/blockers.md
```markdown
# Blockers — Manual Actions Needed

> Written by any agent when human intervention is required.
> Read by the human during daily/weekly check-in.
> Mark items DONE when completed.

---

<!-- Format per blocker:

### [Date] — [Action needed]
**Requested by**: SP-PM / SP-QA / Sprint [XX]
**Action**: [Exactly what the human needs to do]
**Context**: [Why this can't be automated]
**Priority**: [urgent / normal]
**Status**: PENDING / DONE

-->
```

### briefs/weekly-debrief.md
```markdown
# Weekly Debrief

> Auto-generated by /update-briefs on Fridays or on request.
> This is what the human reads to stay informed.

---

<!-- Format:

### Week of [date]

**Sprints completed**: [count]
**Key deliverables**:
- [What was shipped]

**Quality**:
- QA reviews: [X approved, Y with concerns, Z rejected]
- Test suite: [passing/total]

**Decisions made**:
- [Key decisions from decisions-log.md]

**Blockers**:
- [Pending manual actions]

**Next week**:
- [Planned work]

-->
```

## 7. Add briefs/ to .gitignore exception

Make sure briefs/ is NOT gitignored. It should be tracked in git
(it's the audit trail for strategic decisions). Verify .gitignore
does not exclude briefs/.

## 8. Update .claude/rules/general.md

Add a section at the end:

```markdown
## Strategic layer discipline

When the project uses strategic agents (SP-PM, SP-QA):
- briefs/ is the shared memory. Always read before acting, always write after deciding.
- Sprint phases launched via claude -p --bare MUST be separate sessions (context isolation).
- The PM proposes, the QA challenges. Neither should rubber-stamp the other.
- Position changes during debate require explicit new reasoning.
- Maximum 3 debate rounds. If no consensus, escalate to human via blockers.md.
- Maximum 5 sprints per PM session before mandatory QA review.
- All decisions go to decisions-log.md. No undocumented decisions.
```

## 9. Verification

After creating everything, verify:
1. Both agents load: check frontmatter is valid YAML
2. All 3 skills have proper frontmatter with pushy descriptions
3. briefs/ has all 7 files
4. rules/general.md has the strategic layer section
5. No personal data in any new file
6. All content is in English
7. Agent format matches existing agents (architect.md, code-reviewer.md)
8. Skill format matches existing skills (review, capture-lessons)

List any issues found.