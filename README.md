# Claude Code Workflow Template v3.3

> A structured sprint workflow for solo developers and small teams
> using Claude Code. Plan, build, review, fix, ship — with human
> validation at every step.

## Why this exists

Without structure, three things happen with Claude Code:

- **Claude drifts.** Long conversations compact, instructions vanish, code stops following standards.
- **No traceability.** Each session is an island. You don't know what was decided, why, or where things stand.
- **No systematic quality.** The temptation of build-then-ship without review or tests.

**The solution:** a sprint cycle where **skills encode the workflow** and **you only do two things: invoke and validate**. If you're copy-pasting prompts or manually telling Claude what to do, something's wrong — it should be in a skill.

## What's inside

```
.claude/
├── CLAUDE.md                  # Project identity — customize this first
├── settings.json              # Hooks (tests, linter, safety guards)
├── agents/                    # 7 subagents (5 universal + 2 strategic)
│   ├── architect.md           # System design, planning, trade-offs
│   ├── code-reviewer.md       # Quality, conventions, maintainability
│   ├── security-auditor.md    # Vulnerabilities, pentest, attack surface
│   ├── ops-engineer.md        # CI/CD, infra, deploy, monitoring, costs
│   ├── ops-monitor.md         # Operations triage, monitoring diagnostics
│   ├── qa-tester.md           # Test strategy, edge cases, regression
│   ├── strategic-pm.md        # Sprint planning, product decisions (Opus)
│   └── strategic-qa.md        # Sprint review, QA challenge (Opus)
├── skills/
│   ├── sprint-plan/           # /sprint-plan — produces plan.md
│   ├── build/                 # /build — produces build-output.md
│   ├── review/                # /review — produces review-output.md
│   ├── fix/                   # /fix — produces fix-output.md
│   ├── red-team/              # /red-team — produces attack scripts + report
│   ├── capture-lessons/       # /capture-lessons — PR, retro, lessons
│   ├── full-sprint/           # /full-sprint — autonomous end-to-end sprint
│   ├── smoke-test/            # /smoke-test — post-sprint validation
│   ├── update-briefs/         # /update-briefs — sync shared memory
│   ├── product-verification/  # /product-verification — end-to-end QA
│   ├── data-analysis/         # /data-analysis — metrics, analytics
│   ├── scaffolding/           # /scaffolding — boilerplate generation
│   ├── runbook/               # /runbook — incident investigation
│   ├── remote-fix/            # /remote-fix — quick fixes from phone
│   ├── monitoring-briefing/   # /monitoring-briefing — status summary
│   └── frontend-slides/       # /frontend-slides — HTML presentations
└── rules/                     # Conventions, auto-loaded by file path
    ├── general.md             # Code quality, git, testing, session discipline
    ├── backend/api.md         # REST, validation, auth, performance
    ├── frontend/components.md # Components, state, accessibility
    ├── security/auth.md       # Crypto, sessions, secrets, input handling
    └── infra/cicd.md          # Pipelines, Docker, deploy, observability

briefs/                        # Strategic shared memory (SP-PM ↔ SP-QA)
├── direction.md               # Human vision and milestones (you write this)
├── project-state.md           # Current state — updated after each sprint
├── sprint-directive.md        # Next sprint "order" — written by SP-PM
├── decisions-log.md           # Append-only decision audit trail
├── qa-review.md               # SP-QA findings and verdicts
├── blockers.md                # Manual actions needed by human
├── marketing-sync.md          # User-facing changes for comms
└── weekly-debrief.md          # Auto-generated weekly summary

tasks/
├── backlog.md                 # Product backlog — prioritized items
├── lessons.md                 # Knowledge capital — grows every sprint
└── sprints/sprint-XX/         # Sprint artifacts (plan, build, review, fix, retro)

monitoring/                    # Scheduled task outputs (health, CVE, reports)

docs/
├── WORKFLOW.md                # Full workflow documentation
├── REFERENCES.md              # Engineering references and sources
├── scheduled-tasks-prompts.md # Ready-to-use scheduled task prompts
├── mac-persistent-setup.md    # macOS persistent session setup guide
└── prompt-starter.md          # Strategic partner prompt template
```

## Quick start

**1. Fork this repo** on GitHub, then clone your fork:

```bash
gh repo fork example/generic --clone
cd generic
```

> No GitHub CLI? Fork via the GitHub UI, then `git clone <your fork URL>`.

**2. Customize for your project:**

- `.claude/CLAUDE.md` — project name, tech stack, conventions *(start here)*
- `tasks/backlog.md` — your first backlog items

**3. Verify the setup:**

```bash
bash verify-v33.sh
```

**4. Open Claude Code and plan your first sprint:**

```bash
claude
> /sprint-plan
```

### What to customize

| File | When |
|------|------|
| `.claude/CLAUDE.md` | First — your project vision, stack, conventions |
| `tasks/backlog.md` | First — your initial product backlog |
| `.claude/rules/` | When a code area needs specific conventions |
| `.claude/agents/` | After 2-3 sprints — add project-specific agents |
| `.claude/skills/` | When a manual task is done > 2 times |

### What NOT to customize

The sprint cycle skills (`/sprint-plan`, `/build`, `/review`, `/fix`, `/red-team`, `/capture-lessons`) work as-is. If a skill misbehaves, the issue is almost always in `CLAUDE.md` (missing project context) or `rules/` (missing conventions) — not in the skill itself.

## The sprint cycle

```
/sprint-plan  →  /build  →  /review  →  /fix  →  /capture-lessons
     │              │            │          │            │
  Validate       Validate    Triage     Validate     Merge PR
  the plan       the build   issues     the fixes    next sprint
```

Three sprint types depending on the stakes:

| Type | Phases | When |
|------|--------|------|
| **Hotfix** | `/build` → deploy | Prod bug, < 3 files, urgent |
| **Normal** | Full cycle (no red-team) | Standard feature sprint |
| **Security** | Full cycle + `/red-team` | Auth, billing, data, pre-release |

Each phase runs in its own Claude Code session. The handoff between phases goes through files in `tasks/sprints/sprint-XX/`. This is intentional — a fresh session gives a more critical review.

### Key rules

- **One phase = one session.** Never continue after a skill says STOP.
- **Use `/compact` within phases, `/clear` between phases.** Compact preserves progress, clear gives fresh context.
- **The human validates between phases.** Claude is autonomous within a phase, not across phases.
- **Lessons accumulate.** Every skill reads `tasks/lessons.md` at the start. Every sprint adds to it.

## Strategic layer (v3.3)

The strategic layer adds autonomous sprint orchestration on top of the manual cycle. Two strategic agents — **SP-PM** (Strategic Product Manager) and **SP-QA** (Strategic QA) — operate autonomously, communicate via `briefs/`, and can run multiple sprints without human intervention between them.

```
Human writes briefs/direction.md
         ↓
SP-PM reads direction + backlog → writes sprint-directive.md
         ↓
/full-sprint executes all phases (context-isolated claude -p sessions)
         ↓
SP-QA reads sprint output → writes qa-review.md
         ↓
SP-PM reads qa-review → plans next sprint or escalates to blockers.md
```

The key design principle: **generator/evaluator separation**. SP-PM never reviews its own sprints. SP-QA never plans. Research shows agents are bad at self-evaluation — structural separation enforces it.

| File | Who writes | Who reads |
|------|-----------|-----------|
| `briefs/direction.md` | Human | SP-PM |
| `briefs/sprint-directive.md` | SP-PM | `/full-sprint`, `/sprint-plan` |
| `briefs/project-state.md` | SP-PM (via `/update-briefs`) | SP-PM, SP-QA |
| `briefs/qa-review.md` | SP-QA | SP-PM |
| `briefs/decisions-log.md` | SP-PM + SP-QA | SP-QA |
| `briefs/blockers.md` | Any agent | Human |

**To start autonomous mode:** fill `briefs/direction.md` with your vision, then open Claude Code and say `> what should we build next` — SP-PM takes it from there.

## Agents

5 universal agents cover any project type. 2 strategic agents orchestrate autonomous sprints. 2 optional slots for project-specific needs.

| Agent | Domain | Model | When invoked |
|-------|--------|-------|-------------|
| `architect` | System design, planning, trade-offs | Opus | Sprint planning, technical decisions |
| `code-reviewer` | Quality, conventions, maintainability | Opus | Review phase |
| `security-auditor` | Vulnerabilities, pentest, attack surface | Opus | Red-team phase, security sprints |
| `ops-engineer` | CI/CD, infra, deploy, monitoring, costs | Sonnet | Infra changes, deployment |
| `qa-tester` | Test strategy, edge cases, regression | Sonnet | After build, during review |
| `ops-monitor` | Operations triage, monitoring diagnostics | Sonnet | Alert processing, status checks |
| `strategic-pm` | Sprint planning, product decisions, orchestration | Opus | Autonomous sprint execution |
| `strategic-qa` | Sprint review, QA challenge, quality gate | Opus | Post-sprint validation |

All agents have `memory: project` — they accumulate knowledge across sessions.

### Optional project-specific agents (2 slots)

Don't create them "just in case." Wait until a real need emerges after 2-3 sprints. Examples:
- `product-reviewer.md` — UX/copy/consistency for user-facing products
- `billing-auditor.md` — Payment business logic verification
- `ml-engineer.md` — Model training, evaluation, data pipeline

## Skills

### Sprint cycle (6 mandatory)

| Skill | Produces | What it does |
|-------|----------|-------------|
| `/sprint-plan` | `plan.md` | Reads backlog + lessons, invokes architect, produces plan with tasks/risks/alternatives |
| `/build` | `build-output.md` | Implements each task, tests, checkpoints progress incrementally |
| `/review` | `review-output.md` | Invokes code-reviewer + ops-engineer + qa-tester in parallel, conditional project reviewers |
| `/fix` | `fix-output.md` | Triages findings, fixes blocking/major issues, 3-strikes guard |
| `/red-team` | `redteam-output.md` | Generates executable attack scripts across 10 attack categories |
| `/capture-lessons` | PR + `retrospective.md` | Updates lessons.md, backlog, creates PR |

### Strategic layer (3 skills — v3.3)

| Skill | Produces | What it does |
|-------|----------|-------------|
| `/full-sprint` | Full sprint artifacts | Runs all phases autonomously via `claude -p --bare`, context-isolated |
| `/smoke-test` | `smoke-test-output.md` | Post-sprint regression check, test suite, health checks |
| `/update-briefs` | Updated `briefs/` files | Syncs project-state, marketing-sync, blockers, decisions-log |

### Utility skills (7 optional)

| Skill | Purpose |
|-------|---------|
| `/product-verification` | End-to-end functional testing |
| `/data-analysis` | Metrics extraction, analytics, reporting |
| `/scaffolding` | Project structure and boilerplate generation |
| `/runbook` | Incident investigation, structured reports |
| `/remote-fix` | Quick fixes from phone via Telegram/Discord |
| `/monitoring-briefing` | 5-10 line status summary from monitoring data |
| `/frontend-slides` | Animation-rich HTML presentations |

## Hooks

5 hooks in `settings.json` that enforce quality deterministically. Unlike natural language instructions, a hook **always executes**.

| Hook | Event | What it guarantees |
|------|-------|-------------------|
| **Stop** | Phase ends | Tests must pass before declaring "done" |
| **PostToolUse** | Write/Edit | Auto-lints code after every modification (eslint, ruff, flake8) |
| **PreToolUse** | Bash | Blocks destructive commands (rm -rf, DROP TABLE, etc.) |
| **SubagentStop** | Subagent finishes | Validates output completeness |
| **Notification** | Human attention needed | Desktop notification (macOS/Linux) |

Two types: **command** (shell script, deterministic) and **prompt** (LLM judges yes/no — for checks requiring judgment).

## Scheduled tasks

Three levels depending on what the task needs:

| Need | Type | Command |
|------|------|---------|
| Repo access only (no credentials) | Cloud | `/schedule` in Claude Code |
| Local credentials (AWS, GCP CLI) | Desktop | Schedule tab in Claude Desktop |
| External connectors (Slack, Gmail) | Desktop/Cowork | Desktop scheduled tasks or Cowork |
| Temporary monitoring | Session | `/loop` in Claude Code CLI |

### Recommended tasks

| Task | Frequency | Type | Purpose |
|------|-----------|------|---------|
| Dependency Watch | Daily | Cloud | CVE scanning, contextualized to your code |
| Backlog Hygiene | Weekly | Cloud | Stale items, missing metadata, duplicates |
| Docs Drift | Weekly | Cloud | Documentation/code coherence |
| Weekly Retro | Weekly | Cloud | Sprint recap, metrics summary |
| Test Health | Daily | Cloud | Test suite status and failures |
| Health Check | Every 3h | Desktop | Cloud infrastructure health via local CLI |
| Daily Brief | Daily | Desktop/Cowork | Morning briefing from connected tools |

Full prompts in `docs/scheduled-tasks-prompts.md`.

## Remote ops

Three modes for working away from your desk:

| Mode | Tool | Best for |
|------|------|---------|
| **Remote Control** | Claude mobile app (Dispatch) | Full UI, sprint management |
| **Channels** | Telegram or Discord | Quick fixes, monitoring, phone ops |
| **Cloud agents** | `/schedule` | Runs independently, no laptop needed |

### Sprint from your phone

```
Phone (Telegram) → "status"            → /monitoring-briefing
Phone (Telegram) → "fix this: <error>" → /remote-fix
Phone (Dispatch) → full sprint phases with validation
Cloud agents    → dependency audit, test health (run autonomously)
```

For persistent sessions on macOS, see `docs/mac-persistent-setup.md`.

## Monitoring

All scheduled task outputs converge in `monitoring/`:

```
monitoring/
├── dependency-watch-latest.md      # CVE scanning results
├── backlog-hygiene-latest.md       # Backlog audit
├── docs-drift-latest.md            # Documentation drift
├── weekly-retro-latest.md          # Weekly summary
├── test-health-latest.md           # Test suite status
├── health-check-latest.md          # Infrastructure health
├── alerts/                         # Active alerts (critical CVEs, test failures)
└── *.tmp, *.log                    # Temporary files (gitignored)
```

The `/monitoring-briefing` skill reads these files and produces a 5-10 line status summary, designed for phone consumption.

## Aligned with Anthropic's best practices

This workflow's architecture is validated by engineering insights from the Claude Code team at Anthropic.

| Concept | Anthropic finding | Workflow implementation |
|---------|------------------|----------------------|
| Progressive disclosure | Don't dump context, let agents search | CLAUDE.md ~100 lines, skills with frontmatter stubs, rules scoped by path |
| Generator/Evaluator separation | Agents are bad at self-evaluation | /build (generator) then /review (evaluator) in separate sessions |
| Context resets | Compaction alone causes context anxiety | /clear between phases, /compact within phases |
| File system as state | Elegant state representation for agents | tasks/ for project state, monitoring/ for ops, handoff via sprint files |
| Prompt caching | Static first, dynamic last, never change mid-session | CLAUDE.md stable, rules via messages, no model/tool changes mid-session |
| Tools evolve with models | Old tools may constrain new models | Principle 8: review skills every 2-3 months |
| Planner is essential | Without planning, agents under-scope | Principle 1: plan first, never code without a plan |
| Deterministic verification | Linting > LLM judgment for verification | Hooks: Stop (tests), PostToolUse (linter), PreToolUse (safety) |

Full references with links in `docs/REFERENCES.md`.

## Verification

Run the verification script to validate your setup:

```bash
bash verify-v33.sh
```

Checks all components: file structure, agent frontmatter, skill quality (STOP directives, Gotchas, triggers, memory sections), workflow features (conditional reviewers, compact protection, 3-strikes guard), hooks, strategic layer (agents, skills, briefs/ directory).

## Built with this workflow

- *Your project here — open a PR to be listed!*

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
