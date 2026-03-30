# Workflow v4 — Autonomous Strategic Layer

> **Status**: Design phase — not yet implemented
> **Prerequisite**: Workflow v3.2 (sprint cycle, agents, skills, hooks, monitoring)
> **Goal**: Add an autonomous strategic layer that plans, executes, and reviews
> sprints with minimal human intervention.

---

## 1. Vision

### What changes from v3.2

| | v3.2 (current) | v4 (target) |
|---|---|---|
| **Human role** | PM/PO — invokes each phase, validates each result | Director — gives direction, validates milestones |
| **Sprint trigger** | Human types /sprint-plan | SP-PM decides based on backlog + direction |
| **Phase transitions** | Human types /clear then /build, /review, etc. | Automated via claude -p --bare per phase |
| **Quality gate** | Human reviews between phases | SP-QA reviews post-sprint, hooks enforce in-phase |
| **Routing** | Human copies between conversations | File-based communication (briefs/) |
| **Strategic decisions** | Human + SP in Desktop conversation | SP-PM + SP-QA debate asynchronously or via Agent Teams |

### What does NOT change

The sprint cycle itself is identical. Skills, agents, hooks, rules, monitoring,
lessons.md, handoff files — all unchanged. v4 is a layer ABOVE v3.2, not a
replacement.

### The honest assessment

This system is buildable today with experimental tools. The PM→QA debate
pattern is theoretically sound and empirically validated by research. But
"research preview" means occasional orphaned agents, context compaction
bugs, and debate loops that require human intervention. The human-at-milestone
validation is not just a safety measure — it's a practical necessity given
the current maturity of the tooling.

Build iteratively: start with a single automated sprint, validate quality
parity with human-supervised sprints, then expand scope.

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────┐
│  HUMAN (Director)                                       │
│                                                         │
│  Inputs:                                                │
│    briefs/direction.md → vision, milestones, priorities  │
│    blockers.md actions → manual tasks (Stripe, DNS...)   │
│                                                         │
│  Reads:                                                 │
│    briefs/weekly-debrief.md → what happened this week    │
│    briefs/blockers.md → what needs human action          │
│    PRs on GitHub → final validation before merge         │
│                                                         │
│  Frequency: daily check (5 min) or weekly (30 min)      │
│                                                         │
└──────────────────┬──────────────────────────────────────┘
                   │
                   │ briefs/ (shared memory, git-versioned)
                   │
┌──────────────────┴──────────────────────────────────────┐
│  STRATEGIC LAYER                                        │
│                                                         │
│  ┌─────────────────────────────────────────────┐        │
│  │  SP-PM (Product Manager)                    │        │
│  │  Model: Opus (or Mythos when available)     │        │
│  │  Persona: "proposer"                        │        │
│  │  Session: claude --agent=strategic-pm       │        │
│  │                                             │        │
│  │  Reads:                                     │        │
│  │    briefs/direction.md                      │        │
│  │    briefs/project-state.md                  │        │
│  │    briefs/qa-review.md (QA's last feedback) │        │
│  │    tasks/backlog.md                         │        │
│  │    tasks/lessons.md                         │        │
│  │    Latest retrospective                     │        │
│  │                                             │        │
│  │  Writes:                                    │        │
│  │    briefs/sprint-directive.md               │        │
│  │    briefs/decisions-log.md                  │        │
│  │    briefs/project-state.md (after sprint)   │        │
│  │    briefs/marketing-sync.md                 │        │
│  │    briefs/blockers.md                       │        │
│  │                                             │        │
│  │  Executes:                                  │        │
│  │    Sprint phases via claude -p --bare       │        │
│  │    Multiple sprints if QA approves          │        │
│  └─────────────────────────────────────────────┘        │
│                                                         │
│  ┌─────────────────────────────────────────────┐        │
│  │  SP-QA (Tech Lead)                          │        │
│  │  Model: Opus                                │        │
│  │  Persona: "troublemaker"                    │        │
│  │  Session: claude --agent=strategic-qa       │        │
│  │                                             │        │
│  │  Reads:                                     │        │
│  │    briefs/sprint-directive.md               │        │
│  │    tasks/sprints/sprint-XX/* (all outputs)  │        │
│  │    briefs/project-state.md                  │        │
│  │    briefs/decisions-log.md                  │        │
│  │    tasks/lessons.md                         │        │
│  │                                             │        │
│  │  Writes:                                    │        │
│  │    briefs/qa-review.md                      │        │
│  │    Smoke test results                       │        │
│  │                                             │        │
│  │  Does:                                      │        │
│  │    Independent review of sprint results     │        │
│  │    Smoke tests (skill /smoke-test)          │        │
│  │    Challenge PM decisions with evidence     │        │
│  │    Track own agreement rate                 │        │
│  └─────────────────────────────────────────────┘        │
│                                                         │
│  ┌─────────────────────────────────────────────┐        │
│  │  MARKETING (optional, on-demand)            │        │
│  │  Model: Sonnet                              │        │
│  │  Triggered by SP-PM when content needed     │        │
│  │                                             │        │
│  │  Reads: briefs/marketing-sync.md            │        │
│  │  Writes: changelog, posts, release notes    │        │
│  └─────────────────────────────────────────────┘        │
│                                                         │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────┴──────────────────────────────────────┐
│  EXECUTION LAYER (unchanged from v3.2)                  │
│                                                         │
│  Sprint phases via claude -p --bare:                    │
│    Session 1: /sprint-plan → subagent architect         │
│    Session 2: /build → subagents if Agent Teams         │
│    Session 3: /review → subagents code-reviewer,        │
│                          qa-tester                      │
│    Session 4: /fix                                      │
│    Session 5: /capture-lessons                          │
│                                                         │
│  Each session:                                          │
│    - Isolated context (fresh start)                     │
│    - Skills load normally                               │
│    - Subagents invoke normally                          │
│    - Hooks enforce quality (Stop, PostToolUse, etc.)    │
│    - Handoff via files (plan.md → build-output.md → ..) │
│                                                         │
│  Permissions: --dangerously-skip-permissions for dev    │
│  (restrict for production — see section 7)              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Debate protocol (anti-sycophancy)

### The problem

Research shows LLM agents exhibit increasing sycophancy in later debate
rounds. Without countermeasures, the QA agent will agree with the PM
too quickly, rubber-stamping sprint plans and results.

Sources:
- "Peacemaker or Troublemaker" (2025, arXiv:2509.23055)
- Du et al., "Society of Minds" (ICML 2024)
- SWE-Debate (2025) — 41.4% Pass@1 on SWE-bench with adversarial debate
- Irving, Christiano & Amodei (2018) — theoretical foundation

### The protocol

```
ROUND 1 — Independent analysis (mandatory)

  PM: Presents sprint plan with rationale
  QA: Analyzes INDEPENDENTLY without seeing PM's reasoning
      Must produce substantive analysis before any agreement
      If zero issues found → explain WHY in detail
      (the explanation IS the deliverable)
      
  Output: PM writes sprint-directive.md
          QA writes qa-review.md (independently)

ROUND 2 — Structured challenge (if QA found issues)

  QA: Presents objections with specific evidence
  PM: Responds with justifications, cites data
  Both: Report confidence score (0-1)
  
  If both confident > 0.8 → consensus reached, proceed
  If one < 0.5 → go to round 3
  If PM changes position → must explain WHY with new reasoning
     (not just "you're right")

ROUND 3 — Synthesis or escalation (if still disagreeing)

  Synthesis: identify what's agreed vs what's unresolved
  If consensus → proceed with agreed plan
  If deadlock → escalate to human via briefs/blockers.md
  
  HARD STOP after round 3. No round 4. Ever.
```

### Anti-sycophancy safeguards

1. **Persona separation**: PM system prompt says "proposer — your job is
   to advocate for your plan." QA system prompt says "troublemaker — your
   job is to find what's wrong."

2. **No minimum issue count**: Do NOT say "find at least 2 issues." This
   causes invented issues. Say "find ALL genuine issues. If there are none,
   explain why everything is solid."

3. **Agreement rate tracking**: If QA approved the last 3 sprints without
   major findings, automatically increase scrutiny by adding to QA's prompt:
   "You have approved 3 consecutive sprints. Apply extra scrutiny."

4. **Position change justification**: Any agent that changes its position
   must provide new reasoning. "I agree" without explanation is forbidden.

5. **Confidence score tracking**: If an agent's confidence drops from 0.9
   to 0.3 without substantive new arguments, flag as potential capitulation.

6. **Convergence detection**: Consensus is genuine when:
   - Both agents confident > 0.7
   - Sustained for 2 rounds
   - Position changes are justified with new evidence

---

## 4. The multi-sprint autonomous flow

### Semi-permanent session approach

The SP-PM runs as a longer session that orchestrates multiple sprints.
It's not truly 24/7 — it runs for a batch of work (e.g., "build the
MVP" or "complete these 5 backlog items") then stops.

```
Human launches: claude --agent=strategic-pm
  
PM reads:
  briefs/direction.md → "Build payment system MVP"
  briefs/project-state.md → current state
  briefs/qa-review.md → QA feedback from last sprint
  tasks/backlog.md → available work
  tasks/lessons.md → past mistakes

PM plans Sprint N:
  → Writes briefs/sprint-directive.md
  → Writes briefs/decisions-log.md (append)

PM executes Sprint N (isolated phases):
  → claude -p --bare "Read sprint-directive.md, execute /sprint-plan"
  → claude -p --bare "Read plan.md, execute /build"  
  → claude -p --bare "Read build-output.md, execute /review"
  → claude -p --bare "Read review-output.md, execute /fix"
  → claude -p --bare "Execute /capture-lessons"

PM reads results:
  → tasks/sprints/sprint-N/retrospective.md
  → Were there critical issues? → if yes, stop and escalate
  → Were tests passing? → if no, stop and escalate

PM updates state:
  → briefs/project-state.md
  → briefs/marketing-sync.md (if user-facing changes)
  → briefs/blockers.md (if manual actions needed)

PM decides: another sprint or stop?
  → If direction.md milestone reached → stop, write debrief
  → If backlog has more work → plan Sprint N+1
  → If blockers → stop, wait for human
  → If QA review needed → stop, trigger QA

Human launches: claude --agent=strategic-qa
  
QA reads all sprint outputs + PM decisions
QA writes qa-review.md
QA runs /smoke-test if applicable

If QA found issues:
  → Human relaunches PM with qa-review.md context
  → Round 2 of debate (max 3 rounds total)

If QA approves:
  → PM can continue to next batch of sprints
```

### Why semi-permanent, not fully permanent

- Avoids the compaction bug (#23620) — PM session stays within context limits
- Each "batch" is 1-5 sprints — fits within a Max plan session window
- QA runs in a separate session — fresh context, genuine independence
- Human checkpoints between batches (PR review, blockers)
- No token waste from idle polling

### Permission handling for autonomous execution

For development/MVP phase, use permissive settings:

```json
{
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Grep", "Glob",
      "Bash", "WebFetch"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(rm -rf ~)",
      "Bash(DROP TABLE)",
      "Bash(DROP DATABASE)",
      "Bash(git push --force)",
      "Bash(git push origin main)"
    ]
  }
}
```

For `claude -p` headless sessions, add `--dangerously-skip-permissions`
to avoid blocking on permission prompts (no human to approve).

For production: remove the skip flag, restrict Bash to read-only,
require human approval for deploys.

---

## 5. Hooks and guardrails for strategic agents

### Existing hooks (unchanged, apply to sprint phases)

| Hook | What it does |
|------|-------------|
| Stop | Tests must pass before "done" |
| PostToolUse | Linter after every file edit |
| PreToolUse | LLM judges if bash commands are dangerous |
| SubagentStop | Validates subagent output completeness |
| Notification | Desktop alert when waiting for human |

### New guardrails for strategic agents (encoded in agent prompts)

**SP-PM non-negotiable rules:**
```
- NEVER start a sprint without writing sprint-directive.md first
- NEVER scope more than 5-8 files modified per sprint
- ALWAYS read qa-review.md before planning the next sprint
- ALWAYS update project-state.md after each sprint completes
- ALWAYS update decisions-log.md with rationale for every decision
- If a sprint fails (tests don't pass after /fix) → do NOT retry
  the same sprint. Escalate to blockers.md with diagnosis.
- If blocked by manual action → write to blockers.md and STOP
- If QA flags critical issue → address before next sprint
- If 3 consecutive sprints fail → STOP and escalate to human
- Maximum 5 sprints per session before stopping for QA review
```

**SP-QA non-negotiable rules:**
```
- NEVER approve without reading ALL sprint output files
- NEVER agree with PM without independent analysis first
- ALWAYS run the test suite before approving
- ALWAYS check lessons.md for recurring issues
- If zero issues found → explain WHY in detail
  (the explanation IS your deliverable)
- Track your agreement rate. If you approved the last 3 sprints
  without major findings → apply extra scrutiny on the next one.
- If you find a regression (something that worked before is now broken)
  → flag as CRITICAL, do not approve
- If sprint scope exceeded plan (more files changed than planned)
  → flag as concern
- After QA review → STOP. Do not continue to next sprint yourself.
```

### Recovery patterns

```
Sprint fails (tests don't pass after /fix):
  → PM does NOT retry same sprint
  → PM writes diagnosis in blockers.md
  → PM plans a hotfix sprint with reduced scope
  → If hotfix also fails → escalate to human

QA finds regression:
  → Next sprint type = hotfix (not feature)
  → Regression fix is sole focus
  → QA re-runs full test suite after fix

QA finds critical security issue:
  → Sprint result is BLOCKED
  → Escalate to human immediately
  → Do not proceed with any further sprints

Context approaching limits (>60%):
  → PM wraps up current sprint
  → Writes full state to briefs/
  → Stops session
  → Next session picks up from briefs/
```

---

## 6. briefs/ — shared memory structure

```
briefs/
├── direction.md              ← Human writes: vision, milestones, priorities
├── project-state.md          ← PM updates: current state after each sprint
├── sprint-directive.md       ← PM writes: scope and tasks for next sprint
├── decisions-log.md          ← PM appends: every decision with rationale
├── qa-review.md              ← QA writes: review of latest sprint
├── marketing-sync.md         ← PM writes: user-facing changes for marketing
├── blockers.md               ← Anyone writes: manual actions needed
└── weekly-debrief.md         ← Auto-generated: summary for human
```

### File format conventions

- **Markdown** for all briefs (human-readable, agent-friendly)
- **Append-only** for decisions-log.md (never overwrite, always add)
- **Overwrite** for project-state.md (always current state)
- **Atomic writes** (write to .tmp then rename — prevents partial reads)
- **Git versioned** (full audit trail of every change)

### direction.md template

```markdown
# Project Direction

## Vision
[What we're building and why — 2-3 sentences]

## Current milestone
[What we're working toward right now]
Deadline: [if any]
Success criteria: [how we know it's done]

## Priorities (ordered)
1. [Most important thing]
2. [Second most important]
3. [Third]

## Constraints
- [Budget, time, technical constraints]

## What NOT to do
- [Explicitly out of scope]

## Manual actions pending
- [ ] [Action the human needs to do]

Last updated: [date]
```

---

## 7. Token economics

### Max plan comparison

| Plan | Cost | Sonnet hours/5h window | Opus hours/5h window | Best for |
|------|------|----------------------|---------------------|----------|
| Max 5x | $100/month | ~17.5h equivalent | ~3.5h equivalent | 1-2 sprints/day |
| Max 20x | $200/month | ~70h equivalent | ~14h equivalent | 3-5 sprints/day, multi-agent |
| API (Sonnet) | ~$3/$15 per 1M tokens | Unlimited (pay per use) | Unlimited | 24/7 continuous |

### Estimated consumption per autonomous sprint

```
Component                    Tokens (approx)    Model     Cost (API)
─────────────────────────────────────────────────────────────────────
SP-PM planning               50K in + 10K out   Opus      $0.50
Sprint plan phase            30K in + 10K out   Sonnet    $0.24
Build phase                  80K in + 30K out   Sonnet    $0.69
Review phase (2 subagents)   60K in + 20K out   Sonnet    $0.48
Fix phase                    40K in + 15K out   Sonnet    $0.35
Capture lessons              20K in + 10K out   Sonnet    $0.21
SP-QA review                 50K in + 10K out   Opus      $0.50
─────────────────────────────────────────────────────────────────────
Total per sprint             330K in + 105K out            ~$3.00
With 90% cache hit rate                                    ~$0.80
```

### Projections

| Scenario | Sprints | API cost (cached) | Max 5x | Max 20x |
|----------|---------|-------------------|--------|---------|
| MVP (2-3 weeks) | 15 | ~$12-45 | Fits ✅ | Fits ✅ |
| Monthly maintenance | 8-12 | ~$7-36 | Fits ✅ | Fits ✅ |
| Intensive week | 10-15 | ~$8-45 | Tight ⚠️ | Fits ✅ |
| 24/7 continuous (1 month) | 60+ | ~$48-180 | No ❌ | Tight ⚠️ |

### Recommendation

**Start with Max 5x** (your current plan). Run 1-2 autonomous sprints,
measure actual consumption. If you hit limits regularly, upgrade to Max 20x.
API is for true 24/7 continuous operation — not needed until you have
multiple projects running autonomously.

Your observation: 2 manual sprints = 30-40% of a 5h window. Autonomous
sprints should be similar (same skills, same agents). The overhead is
the SP-PM/QA debate (~10-15% additional).

### Cost optimization strategies

1. **Sonnet for execution, Opus for decisions only** — PM and QA use Opus,
   all sprint phases use Sonnet. This is the biggest lever.
2. **--bare for sprint phases** — skip auto-discovery, faster startup,
   fewer tokens on context loading.
3. **Prompt caching** — keep CLAUDE.md and skills stable (don't modify
   mid-sprint). Cache hit rate is the second biggest lever.
4. **Batch sprints** — run 3-5 sprints in one PM session rather than
   launching PM fresh each time (amortizes PM context loading).
5. **Sonnet for QA on non-critical reviews** — if the sprint is a minor
   fix or docs update, QA can run on Sonnet instead of Opus.

---

## 8. Skills to create

### /full-sprint

```
Orchestrates a complete sprint via claude -p --bare.
Each phase runs in an isolated headless session.
Skills and subagents function normally within each session.

Input: sprint-directive.md (from SP-PM)
Output: all sprint files + updated briefs/

Checks after each phase:
  - Did the phase produce its expected output file?
  - If not → retry once, then escalate
  - After /review: were there critical issues?
    If yes → proceed to /fix (normal flow)
  - After /fix: do tests pass?
    If no → escalate, do NOT retry indefinitely
```

### /smoke-test

```
Post-sprint validation. Runs after /capture-lessons.
Verifies the application works as expected.

Steps:
1. Run the full test suite
2. Check for regressions (compare test count before/after)
3. If web app: verify key endpoints respond
4. If CLI: verify key commands work
5. Produce smoke-test-output.md with pass/fail per check

Invoked by SP-QA during post-sprint review.
```

### /update-briefs

```
Updates briefs/ after a sprint completes.

Reads: latest sprint outputs (plan, build, review, fix, retro)
Updates:
  - project-state.md (current state, what changed)
  - marketing-sync.md (user-facing changes only)
  - blockers.md (any manual actions discovered)
  - decisions-log.md (append technical decisions made)

Invoked automatically at the end of /full-sprint.
```

---

## 9. New agents

### strategic-pm.md

```yaml
---
name: strategic-pm
description: >
  Product Manager for autonomous sprint orchestration. Plans sprints,
  makes product decisions, executes sprint cycles via claude -p --bare,
  and updates project state. Use when starting a new sprint batch or
  when the human gives new direction.
tools: Read, Grep, Glob, Bash, Write, Edit
model: opus
memory: project
---

You are the Product Manager for this project. You make product decisions
and orchestrate sprint execution.

## Your persona: PROPOSER

You advocate for your plans with evidence and rationale. You are not
a yes-man — you defend your decisions when challenged, but you change
your position when presented with better arguments (with explicit
justification for the change).

## How you work

1. Read briefs/direction.md for the human's vision and milestones
2. Read briefs/project-state.md for current state
3. Read briefs/qa-review.md for QA's feedback on the last sprint
4. Read tasks/backlog.md for available work
5. Read tasks/lessons.md for past mistakes to avoid
6. Plan the next sprint → write briefs/sprint-directive.md
7. Log your decisions → append to briefs/decisions-log.md
8. Execute the sprint via claude -p --bare (one session per phase)
9. Read results, update briefs/project-state.md
10. Decide: another sprint or stop for QA review?

## Non-negotiable rules

[insert rules from section 5]

## Sprint execution

To run a sprint phase, use Bash:
  claude -p --bare --dangerously-skip-permissions \
    "You are working on [project]. Read [input file] and execute /[skill]."

Each phase MUST be a separate claude -p call (context isolation).
Never combine phases in a single call.

## Memory instructions

Save to memory: decisions made, sprint outcomes, recurring blockers,
QA feedback patterns, backlog evolution, velocity trends.
```

### strategic-qa.md

```yaml
---
name: strategic-qa
description: >
  Tech Lead / QA reviewer for autonomous sprint orchestration. Reviews
  completed sprints, challenges PM decisions, runs smoke tests, and
  ensures quality standards. Use after a sprint completes or when
  reviewing PM decisions.
tools: Read, Grep, Glob, Bash
model: opus
memory: project
---

You are the Tech Lead and QA reviewer. You ensure quality and challenge
decisions that could harm the project.

## Your persona: TROUBLEMAKER

Your job is to find what's wrong. You are not adversarial for the sake
of it — you are rigorous. You challenge with evidence. You approve only
when you're genuinely satisfied.

## How you work

1. Read briefs/sprint-directive.md — what was planned
2. Read ALL files in tasks/sprints/sprint-XX/ — what was delivered
3. Read briefs/decisions-log.md — why decisions were made
4. Read tasks/lessons.md — are past mistakes repeating?
5. Independently analyze the sprint results
6. Write briefs/qa-review.md with your assessment
7. Run /smoke-test if applicable
8. Track your agreement rate (in memory)

## Non-negotiable rules

[insert rules from section 5]

## Anti-sycophancy self-check

Before writing your review, ask yourself:
- Am I agreeing because I genuinely found no issues, or because
  it's easier to agree?
- Did I check the same things I would check if a junior developer
  submitted this code?
- Would I approve this if it were going to production tomorrow?
- Have I approved the last 3 sprints? If yes, apply extra scrutiny.

## Memory instructions

Save to memory: quality trends, recurring issues, PM decision patterns,
agreement rate, areas that tend to have bugs, test coverage gaps.
```

---

## 10. Implementation plan

### Phase 1 — Foundation (effort: S, risk: low)

| Step | What | Validation |
|------|------|-----------|
| 1a | Create briefs/ directory with 7 template files | Files exist |
| 1b | Create strategic-pm.md agent | Agent loads with --agent flag |
| 1c | Create strategic-qa.md agent | Agent loads with --agent flag |
| 1d | Test `claude -p --bare` from Bash in Claude Code | Command executes, output file created |
| 1e | Test subagent invocation inside `claude -p` session | /review calls code-reviewer successfully |

**Step 1d is the decisive test.** If it fails, the entire architecture
needs rethinking. If it works, everything else follows.

### Phase 2 — Single sprint automation (effort: M, risk: medium)

| Step | What | Validation |
|------|------|-----------|
| 2a | Create skill /full-sprint | Skill file exists, frontmatter correct |
| 2b | Create skill /update-briefs | Skill file exists |
| 2c | Run ONE automated sprint (same tasks as a recent manual sprint) | Sprint completes, all output files present |
| 2d | Compare review-output.md: automated vs manual | Same severity, similar number of findings |
| 2e | Compare fix-output.md: automated vs manual | All critical/major fixed |

**Step 2d is the quality validation.** If the automated review finds
significantly fewer issues than the manual review, the approach needs
adjustment (likely prompt tuning for the subagents).

### Phase 3 — PM orchestration (effort: M, risk: medium)

| Step | What | Validation |
|------|------|-----------|
| 3a | Write briefs/direction.md for a real milestone | File reflects actual project goals |
| 3b | Launch SP-PM: plans and executes 1 sprint | Sprint completes, briefs/ updated |
| 3c | Launch SP-QA: reviews the sprint | qa-review.md has substantive content |
| 3d | If QA found issues: relaunch PM for round 2 | PM responds to critique, adjusts or defends |
| 3e | Run 3 consecutive sprints via PM | All complete, quality maintained |

### Phase 4 — Multi-sprint batch (effort: M, risk: higher)

| Step | What | Validation |
|------|------|-----------|
| 4a | PM executes 3-5 sprints in one session | All complete, context stays manageable |
| 4b | QA reviews the batch | Substantive review of all sprints |
| 4c | Measure: token consumption, quality scores, debate convergence | Metrics within acceptable range |
| 4d | Create skill /smoke-test | Skill works, catches real issues |

### Phase 5 — Production readiness (effort: L, ongoing)

| Step | What | Validation |
|------|------|-----------|
| 5a | Remove --dangerously-skip-permissions | Permissions handled via settings.json allow/deny |
| 5b | Add monitoring: cost per sprint, QA agreement rate | Dashboard or log file |
| 5c | Add monitoring: quality trend over time | Regression detection |
| 5d | Document in WORKFLOW.md as v4 | Template updated |
| 5e | Test on a second project (different domain) | Validates portability |

---

## 11. Open questions (to resolve during implementation)

1. **Agent Teams vs async debate**: start with async (file-based, separate
   sessions) for reliability. Try Agent Teams synchronous debate later
   if async feels too disconnected. Both approaches work.

2. **When does PM stop?**: after each sprint for QA review? After 3 sprints?
   After milestone reached? Start with "stop after every sprint for QA"
   then relax as confidence grows.

3. **Who merges PRs?**: human for now. PM can create PRs, but merge is
   a human action. Consider auto-merge only after 10+ successful sprints
   with zero post-merge issues.

4. **Voice debrief**: /voice mode exists in Claude Code. When stable via
   Dispatch, the human can get verbal status updates. Not blocking.

5. **Cross-model QA**: running QA on a different provider (GPT, Gemini)
   for truly independent review. Interesting but not necessary to start.
   Explore via SMUX or OpenCode if curiosity demands.

6. **Mythos/Capybara**: when released, evaluate for PM agent. Higher
   capability = better autonomous decisions. Will be more expensive.
   Principle 8 applies: revisit model assignments regularly.

---

## 12. References

### Research

- Irving, Christiano & Amodei (2018) — AI Safety via Debate
- Du et al. (ICML 2024) — Society of Minds multi-agent debate
- "Peacemaker or Troublemaker" (2025, arXiv:2509.23055) — inter-agent sycophancy
- SWE-Debate (2025) — adversarial debate for bug resolution
- CONSENSAGENT (ACL 2025) — dynamic prompt refinement for consensus
- Hu et al. (NeurIPS 2025) — KS statistic for debate convergence

### Commercial systems studied

- Factory AI — Delegator pattern, spec→test→implement→verify
- Devin (Cognition Labs) — autonomous dev, PR-based quality gate
- Qodo — review-first, 15+ specialized review agents

### Tools evaluated

- Claude Code Agent Teams (native) — best for debate, experimental
- SMUX — tmux bridge, cross-model, simple
- Multiclaude — lead/subagent, multiplayer mode
- IttyBitty — Manager/Worker hierarchy, pure bash
- Claude Squad — session multiplexer, most adopted
- Gas Town — most ambitious, most expensive
- OpenCode — cross-model agent teams, event-driven
- Agentrooms — GUI-first, @mention routing

### Anthropic engineering

- All references from docs/REFERENCES.md apply
- Thariq Shihipar: file system as state, prompt caching, progressive disclosure
- Prithvi Rajasekaran: generator/evaluator separation, context resets
- Boris Cherny: --bare, --add-dir, --agent, /voice