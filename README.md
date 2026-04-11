# Claude Code Workflow

> A structured, sprint-based workflow for AI-assisted development with Claude Code. Battle-tested across 53+ sprints in production.

> **April 2026 context.** Anthropic recently shipped Managed Agents, the Advisor tool, Ultraplan, and dynamic scheduled tasks — all pointing toward structured, autonomous, multi-agent workflows. This repository is the artisanal version of that vision: a methodology you can clone today, inspect end-to-end, and adapt to your project. Same direction, different layer of the stack.

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Version](https://img.shields.io/badge/version-3.5.1-green.svg)](CHANGELOG.md)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-orange)](https://docs.claude.com)

---

## Why this exists

Without structure, three things happen when you build with Claude Code:

1. **Claude drifts.** Long conversations get compacted, instructions disappear, code stops respecting standards.
2. **There's no traceability.** Every session is an island. You lose track of what was decided, why, and where you are.
3. **Quality is not systematic.** The temptation is build → ship without review or tests.

This repository is the answer that emerged from running structured AI-assisted development on a real production project for two months. It's a workflow where **skills encode the process** and **the human only does two things: invoke and validate**.

If you find yourself copy-pasting prompts or manually dictating steps to Claude, that's a workflow bug. It should be in a skill.

---

## What this is

A complete project template containing:

- **9 specialized agents** (5 universal + 2 strategic + 1 marketing + 1 ops monitor) with persistent memory
- **17 skills** covering the full sprint cycle and post-launch operations
- **5 deterministic hooks** (test gate, secret scanner, deny-list, notifications)
- **Path-scoped rules** for backend, frontend, infrastructure, and security
- **Two operating modes**: manual (you invoke each phase) and autonomous (the strategic-pm orchestrates)
- **A sprint cycle**: `/sprint-plan → /build → /review → /fix → /red-team → /capture-lessons`

Everything is plain markdown and JSON. Nothing to install beyond Claude Code. Inspect, adapt, fork.

---

## Proof

This workflow was incubated on a real production SaaS over two months before being extracted into this template:

| Metric | Value |
|---|---|
| Sprints shipped | **53+** |
| Incubation period | **~2 months** (February–April 2026) |
| Total Claude API cost | **$1,271.92** (verified via [ccusage](https://github.com/ryoppippi/ccusage)) |
| Without prompt caching | ~$12,000 |
| Cache hit rate | **95%** |
| Autonomous sprint duration | **30–45 minutes** end-to-end |
| Files modified per sprint | 5–8 (typical) |

The full version history with verifiable commit SHAs is in [CHANGELOG.md](CHANGELOG.md). Every claim above is backed by git history you can audit.

> **Hotfix v3.5.1 — discovered during the workflow's own usage on 2026-04-11, fixed before public release.** Two bugs surfaced when the strategic-pm agent ran an autonomous sprint: an ambiguous "one phase = one session" semantic, and a silent failure when `/sprint-plan` activated plan mode in non-interactive mode. Both are documented in the changelog. The workflow caught its own bugs in production — that's the whole point.

---

## Quick start

**Prerequisites:** [Claude Code](https://docs.claude.com/en/docs/claude-code) installed and authenticated.

```bash
# Use the template (creates a clean repo without this template's git history)
# Click "Use this template" on GitHub, or:
git clone https://github.com/rbah31/claude-code-workflow.git my-project
cd my-project
rm -rf .git && git init

# Personalize
# 1. Edit .claude/CLAUDE.md — your project's vision, stack, conventions
# 2. Edit .claude/rules/general.md — your code conventions
# 3. Add items to tasks/backlog.md

# Verify the setup
claude
> /doctor
> /context
```

For your first sprint:

```
> /sprint-plan
```

Validate the plan, then invoke `/build`, `/review`, `/fix`, and `/capture-lessons` in sequence.

For autonomous orchestration once you have 3+ manual sprints under your belt:

```bash
claude --agent=strategic-pm
```

The PM reads `briefs/direction.md`, proposes a sprint, and orchestrates the full cycle without intervention between phases.

---

## How it works

### The sprint cycle

```
  /sprint-plan  →  /build  →  /review  →  /fix  →  /red-team  →  /capture-lessons
       │              │            │           │          │              │
   Human only       Tests        Fresh        Triaged   Pentester       PR + lessons
   invokes &      enforced      reviewer     fixes      attacks         + retro
   validates      by hook       (no build    only       freely         + backlog
                 (Stop)         context)     marked                     update
```

Three sprint types adapt the cycle to the work:

- **Hotfix** — `/build → deploy`. Production bug, urgency, < 3 files.
- **Normal** — `/sprint-plan → /build → /review → /fix → /capture-lessons`. Standard feature sprint.
- **Security** — Full cycle with `/red-team`. Pre-release, auth changes, payment changes, sensitive data.

### Two operating modes

**Manual mode** — You invoke each skill, validate the result, then invoke the next. Each phase runs in its own `claude -p` session for context isolation. Ideal when you're learning the workflow or working on critical changes.

**Autonomous mode** — The `strategic-pm` agent orchestrates the entire cycle, launching each phase as a separate `claude -p` subprocess. The human only validates the final PR. Enable after 3+ successful manual sprints. The `strategic-qa` agent independently reviews each sprint and challenges PM decisions — neither agent reviews its own work.

### Why sessions are isolated

Each phase runs in its own CLI session for two technical reasons (not for human approval):

1. **Context pollution** — Build context biases review. Claude "knows" why the code is the way it is and becomes less critical. Separate sessions = fresh eyes.
2. **Context limits** — A full sprint in one session saturates context above ~60%, degrading quality.

This is **technical isolation**, not a human gate. In autonomous mode, the strategic-pm chains these sessions automatically.

---

## What's in the repo

```
claude-code-workflow/
├── .claude/
│   ├── CLAUDE.md              # Project source of truth (~100 lines)
│   ├── settings.json          # Hooks, permissions
│   ├── agents/                # 9 specialized agents with memory
│   ├── skills/                # 17 skills (sprint cycle + extensions)
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

---

## The 9 agents

| Agent | Role | Model |
|-------|------|-------|
| `architect` | System design, technical planning, sprint planning | Opus |
| `code-reviewer` | Quality, conventions, performance, maintainability | Opus |
| `security-auditor` | Adversarial security audit, red team | Opus |
| `qa-tester` | Test strategy, edge cases, regression | Sonnet |
| `ops-engineer` | CI/CD, infra, deployment, cost optimization | Sonnet |
| `strategic-pm` | Product Manager — sprint orchestration, decisions | Opus |
| `strategic-qa` | Independent reviewer challenging PM decisions | Opus |
| `marketing-strategist` | Positioning, copywriting, user feedback synthesis | Opus |
| `ops-monitor` | First responder, monitoring report triage | Sonnet |

All agents have `memory: project` enabled — they accumulate knowledge across sessions about the codebase, past decisions, and recurring patterns.

---

## The 17 skills

**Sprint cycle (6 core skills):**
`sprint-plan`, `build`, `review`, `fix`, `red-team`, `capture-lessons`

**Autonomous orchestration:**
`full-sprint`, `update-briefs`

**Operations:**
`runbook`, `monitoring-briefing`, `smoke-test`, `product-verification`, `remote-fix`

**Marketing & content:**
`marketing-sync`, `changelog`, `frontend-slides`

**Project setup:**
`scaffolding`, `data-analysis`

---

## Documentation

- [docs/WORKFLOW.md](docs/WORKFLOW.md) — Complete workflow documentation (~960 lines)
- [docs/SECURITY.md](docs/SECURITY.md) — 6-layer defense architecture
- [docs/REFERENCES.md](docs/REFERENCES.md) — External resources and inspiration
- [CHANGELOG.md](CHANGELOG.md) — Version history with verifiable commit SHAs
- [CONTRIBUTING.md](CONTRIBUTING.md) — How to propose changes
- [NOTICE](NOTICE) — Attribution and origin

---

## Built with this workflow

This workflow has been used to ship 53+ sprints of a multi-tenant SaaS in production. It is currently being open-sourced; case studies and project references will be added as the community grows.

Using this workflow on your project? Open a PR to be listed here.

---

## Philosophy

Seven principles that shape every decision in this repo:

1. **Plan first.** Never code without a plan. If it derails, stop and re-plan.
2. **Subagents for everything specialized.** Isolate concerns, keep the main context clean.
3. **Capitalize on every mistake.** Update `lessons.md` after every correction. Agent memory complements this organically.
4. **Prove before declaring "done".** Tests, logs, demo. Hooks enforce this.
5. **Balanced elegance.** Neither hack nor over-engineering.
6. **Claude is autonomous within a phase.** Don't micro-manage. Give scope and context, Claude does the rest.
7. **Simplicity first.** The simplest change that works. Always.

---

## License

Licensed under the [Apache License 2.0](LICENSE).

In short: you can use, modify, distribute, and use this work commercially. You must keep the LICENSE and NOTICE files in your distribution. You don't need to ask permission.

See [NOTICE](NOTICE) for attribution requirements.

---

## Acknowledgments

Built on top of [Claude Code](https://docs.claude.com/en/docs/claude-code) by [Anthropic](https://www.anthropic.com). Inspired by the Claude Code community's experimentation with hooks, subagents, and skills throughout 2025–2026.

This workflow is not affiliated with or endorsed by Anthropic.

---

## Author

**Rayan Aly Bah** — DevSecOps engineer who built this workflow to ship a production SaaS without losing his mind to AI-assisted development drift. Connect on [GitHub](https://github.com/rbah31).

Issues, ideas, war stories: [open an issue](https://github.com/rbah31/claude-code-workflow/issues) or start a [discussion](https://github.com/rbah31/claude-code-workflow/discussions).
