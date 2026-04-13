# Claude Code Workflow

> A nine-agent development team. PM proposes, QA challenges, five technical agents build. You invoke and validate.

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Version](https://img.shields.io/badge/version-3.5.1-green.svg)](CHANGELOG.md)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-orange)](https://code.claude.com/docs/en/overview)

---

## April 2026 context

Anthropic shipped a lot this quarter — managed agents, remote operations from your phone, dynamic scheduled tasks for monitoring without leaving your session. This repo assembles those pieces into a working multi-agent development team you can clone today, inspect end-to-end, and adapt to your project.

---

## Why this exists

**The human only does two things: invoke and validate.** Everything else is encoded in skills.

Without structure, three things happen when you build with Claude Code:

1. **Claude drifts.** Long conversations get compacted, instructions disappear, code stops respecting standards.
2. **There's no traceability.** Every session is an island. You lose track of what was decided, why, and where you are.
3. **Quality is not systematic.** The temptation is build → ship without review or tests.

This repository is the answer that emerged from running structured AI-assisted development on a real production project for two months. If you find yourself copy-pasting prompts or manually dictating steps to Claude, that's a workflow bug. It should be in a skill.

---

## Proof

| Metric | Value |
|---|---|
| Sprints shipped | **55+** |
| Incubation period | **~2 months** (February–April 2026) |
| Total Claude API cost | **$1,394.38** (verified via [ccusage](https://github.com/ryoppippi/ccusage)) |
| Without prompt caching | ~$13,000 |
| Cache hit rate | **95.5%** |
| Autonomous sprint duration | **30–45 minutes** end-to-end |
| Files modified per sprint | 5–8 (typical) |

The full version history with verifiable commit SHAs is in [CHANGELOG.md](CHANGELOG.md). Every claim is backed by git history you can audit.

> **Hotfix v3.5.1** — two bugs surfaced when the strategic-pm ran an autonomous sprint: an ambiguous session semantic and a silent plan mode failure. Both were discovered during the workflow's own usage on 2026-04-11 and fixed before public release. The workflow caught its own bugs in production. That's the point.

---

## The team

![Global Architecture — The three agents that run your sprints](docs/diagrams/architecture.svg)

Three strategic agents run the cycle. Five technical agents do the building.

**Strategic layer** (activate after 3+ manual sprints):

| Agent | Role | Model |
|-------|------|-------|
| `strategic-pm` | Proposes sprint scope, orchestrates all phases autonomously, writes to `briefs/` | Opus |
| `strategic-qa` | Independently challenges PM decisions, reviews every sprint before the next starts | Opus |
| `marketing-strategist` | Peer of the PM — owns market direction, copy, user feedback synthesis | Opus |

**The rule:** no agent reviews its own output. PM and QA are in adversarial relationship by design. Three rounds of disagreement, then it escalates to you.

**Technical layer** (available from sprint 1):

| Agent | Domain | Model |
|-------|--------|-------|
| `architect` | System design, technical planning | Opus |
| `code-reviewer` | Quality, conventions, performance, maintainability | Opus |
| `security-auditor` | Adversarial security audit, red team | Opus |
| `qa-tester` | Test strategy, edge cases, regression | Sonnet |
| `ops-engineer` | CI/CD, infra, deployment, cost optimization | Sonnet |
| `ops-monitor` | First responder, monitoring report triage | Sonnet |

All agents have `memory: project` enabled — they accumulate knowledge about the codebase, past decisions, and recurring patterns across sessions.

---

## How it works

![Sprint Cycle with Artifacts — What each phase produces, what the next phase reads](docs/diagrams/sprint-cycle.svg)

Each phase runs in its own isolated `claude -p` session — not a human approval gate, a technical boundary. Build context biases review; separate sessions give a fresh perspective. A full sprint in one session saturates context past ~60% and degrades quality.

Three sprint types:

- **Hotfix** — `/build → deploy`. Production bug, urgency, fewer than 3 files.
- **Normal** — `/sprint-plan → /build → /review → /fix → /capture-lessons`.
- **Security** — Full cycle with `/red-team`. Auth changes, payments, pre-release.

**Manual mode**: you invoke each skill, validate the result, invoke the next.

**Autonomous mode**: `claude --agent=strategic-pm` — the PM chains all phases without your intervention. The QA reviews every sprint independently. You validate the final PR.

---

## Quick start

**Prerequisites:** [Claude Code](https://code.claude.com/docs/en/overview) installed and authenticated.

```bash
git clone https://github.com/rbah31/claude-code-workflow.git my-project
cd my-project
rm -rf .git && git init

# Personalize
# 1. Edit .claude/CLAUDE.md — your project's vision, stack, conventions
# 2. Edit .claude/rules/general.md — your code conventions
# 3. Add items to tasks/backlog.md

claude
> /doctor
> /context
```

First sprint:

```
> /sprint-plan
```

Validate the plan, then invoke `/build`, `/review`, `/fix`, and `/capture-lessons` in sequence.

Autonomous mode (after 3+ manual sprints):

```bash
claude --agent=strategic-pm
```

The PM reads `briefs/direction.md`, proposes a sprint, and orchestrates the full cycle without intervention between phases.

---

## What's in the repo

```
claude-code-workflow/
├── .claude/
│   ├── CLAUDE.md              # Project source of truth (~100 lines)
│   ├── settings.json          # Hooks, permissions, deny-list (31 patterns)
│   ├── agents/                # 9 specialized agents with persistent memory
│   ├── skills/                # 18 skills (sprint cycle + extensions)
│   └── rules/                 # Path-scoped conventions
├── briefs/                    # Strategic agent shared memory
├── docs/
│   ├── WORKFLOW.md            # Complete workflow documentation
│   ├── SECURITY.md            # 6-layer defense architecture
│   └── REFERENCES.md          # External resources
├── tasks/
│   ├── backlog.md             # Your product backlog
│   └── sprints/sprint-XX/     # Per-sprint artifacts (handoff files)
├── CHANGELOG.md               # Version history with verifiable SHAs
├── LICENSE                    # Apache 2.0
├── NOTICE                     # Attribution and origin
└── README.md
```

### The 18 skills

**Sprint cycle:** `sprint-plan`, `build`, `review`, `fix`, `red-team`, `capture-lessons`

**Autonomous orchestration:** `full-sprint`, `update-briefs`

**Operations:** `runbook`, `monitoring-briefing`, `smoke-test`, `product-verification`, `remote-fix`

**Marketing & content:** `marketing-sync`, `changelog`, `frontend-slides`

**Project setup:** `scaffolding`, `data-analysis`

---

## Philosophy

Eight principles that shape every decision in this repo:

1. **Plan first.** Never code without a plan. If it derails, stop and re-plan.
2. **Subagents for everything specialized.** Isolate concerns, keep the main context clean.
3. **Capitalize on every mistake.** Update `lessons.md` after every correction. Agent memory complements this organically.
4. **Prove before declaring "done".** Tests, logs, demo. Hooks enforce this.
5. **Balanced elegance.** Neither hack nor over-engineering.
6. **Claude is autonomous within a phase.** Don't micro-manage. Give scope and context, Claude does the rest.
7. **Simplicity first.** The simplest change that works. Always.
8. **Revisit regularly.** Skills and agents must evolve with model capabilities. If the model naturally does what a skill tells it, simplify the skill. Gotchas and business context are more durable than rigid steps.

---

## Documentation

- [docs/WORKFLOW.md](docs/WORKFLOW.md) — Complete workflow documentation
- [docs/SECURITY.md](docs/SECURITY.md) — 6-layer defense architecture
- [docs/REFERENCES.md](docs/REFERENCES.md) — External resources and inspiration
- [CHANGELOG.md](CHANGELOG.md) — Version history with verifiable commit SHAs
- [CONTRIBUTING.md](CONTRIBUTING.md) — How to propose changes
- [NOTICE](NOTICE) — Attribution and origin

---

## License

Licensed under the [Apache License 2.0](LICENSE).

In short: you can use, modify, distribute, and use this work commercially. You must keep the LICENSE and NOTICE files in your distribution. You don't need to ask permission.

See [NOTICE](NOTICE) for attribution requirements.

---

## Author

**Rayan Aly Bah** — DevSecOps engineer who built this workflow to ship a production SaaS without losing his mind to AI-assisted development drift. Connect on [GitHub](https://github.com/rbah31).

Issues, ideas, war stories: [open an issue](https://github.com/rbah31/claude-code-workflow/issues) or start a [discussion](https://github.com/rbah31/claude-code-workflow/discussions).

---

## Acknowledgments

Built on top of [Claude Code](https://code.claude.com/docs/en/overview) by [Anthropic](https://www.anthropic.com). Inspired by the Claude Code community's experimentation with hooks, subagents, and skills throughout 2025–2026.

This workflow is not affiliated with or endorsed by Anthropic.
