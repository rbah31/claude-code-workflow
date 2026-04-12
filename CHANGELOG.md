# Changelog

All notable changes to this workflow are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## Background

This workflow was incubated for two months on a real production project (53+
sprints) before being extracted into this public template on 2026-03-29. The
pre-extraction history (v0 → v3.1) lives in the original private project; the
public history starts at v3.2 with commit `b48149d`.

All commit SHAs below are verifiable in this repository's git history via
`git show <SHA>`.

---

## [3.5.1] — 2026-04-11 — Hotfix

### Fixed

Two bugs discovered during autonomous sprint orchestration on the proving-ground
project, fixed before public release:

- **Session semantic ambiguity.** The phrase "one phase = one session" in
  `CLAUDE.md` was interpreted by the strategic-pm agent as requiring human
  approval between phases, contradicting autonomous orchestration. Now
  explicit: sessions are technical CLI isolation; the PM chains all phases
  without PO intervention. Affected files: `.claude/CLAUDE.md`,
  `docs/WORKFLOW.md`, `.claude/agents/strategic-pm.md`.

- **Plan mode + non-interactive `claude -p` = silent exit 0.** Step 3 of the
  `sprint-plan` skill instructed switching to plan mode (read-only). In
  `claude -p` sessions, plan mode terminates via ExitPlanMode awaiting human
  approval, causing exit 0 with empty output and no `plan.md` written. Now:
  read-only discipline without activating plan mode, with explicit Write tool
  instruction in the save step. Affected file: `.claude/skills/sprint-plan/SKILL.md`.

These bugs were caught by the workflow's own usage in production, demonstrating
the value of dogfooding before public release.

---

## [3.5] — 2026-04-05 to 2026-04-07

### Added

- **Marketing layer as PM peer.** New `marketing-strategist` agent operates
  as a peer to the strategic-pm, not a subordinate. Communication via
  `briefs/marketing-directive.md` files, never response files. Anti-sycophancy
  triangle PM ↔ QA ↔ Marketing — each agent challenges the others.
  Commit: `54a88d9` — *feat: upgrade workflow to v3.5 — marketing layer as PM peer*

- **Anti-sycophancy wiring.** Each strategic agent has explicit "PROPOSER /
  CHALLENGER" personas with rules like "I agree without explanation is
  forbidden". Forces evidence-based debate.
  Commit: `0bb1be8` — *feat(agents): wire PM ↔ QA ↔ Marketing anti-sycophancy triangle*

- **Audit + 8 missing items documented.** Comprehensive workflow audit covering
  agent invocation patterns, session discipline, and undocumented behaviors.
  Commit: `5617f29` — *docs: complete v3.5 audit — 8 missing items documented*

### Changed

- **`/effort high` enabled by default.** Higher reasoning effort for all
  strategic agents. Removed misleading `--bare` flag warnings.
  Commits: `f59991f` — *docs: add /effort high guidance + reinforce --bare warning*
  and `c6f769b` — *fix(workflow): add effort high by default and remove bare flag*

### Pre-release cleanup

- Pre-publication cleanup: removed all client-specific references, unified
  author attribution, gitignored runtime artifacts.
  Commit: `18b53a5` — *chore: pre-publication cleanup for public GitHub release*

---

## [3.4] — 2026-04-05 — Security hardening

### Added

- **Headless mode security hardening.** Comprehensive deny-list (31 patterns)
  for `PreToolUse(Bash)` blocking destructive commands. Secret scanner hooks
  on `PostToolUse(Write|Edit)` detecting AWS keys, Stripe keys, GitHub tokens,
  PEM blocks. Pre-write block on files containing existing secrets.
  Commit: `213dc0e` — *feat: upgrade workflow to v3.4 — headless mode security hardening*

- **Reinforced PreToolUse hook.** Additional hardening on the deny-list and
  Bash command interception for autonomous (`--dangerously-skip-permissions`)
  workflows.
  Commit: `dd5a3a1` — *chore(security): harden deny-list and PreToolUse hook for headless mode*

---

## [3.3] — 2026-04-04 — Strategic layer

### Added

- **Strategic layer for autonomous sprint orchestration.** Two new agents:
  - `strategic-pm` — Product Manager that plans sprints, makes product
    decisions, and orchestrates phase execution autonomously.
  - `strategic-qa` — Independent reviewer that challenges PM decisions.
- **`briefs/` shared memory directory** for inter-agent communication
  (direction, sprint-directive, project-state, decisions-log, qa-review).
- New skills: `full-sprint`, `update-briefs`, `smoke-test`.
- The strategic layer enables end-to-end autonomous sprint cycles while
  preserving human gates at sprint boundaries.

  Commit: `3fa4bc7` — *feat: add v3.3 strategic layer — autonomous sprint orchestration*

---

## [3.2] — 2026-03-29 — Public extraction

### Added

- **Initial public extraction.** The workflow is extracted from its origin
  project into a dedicated, reusable template repository.
- 5 universal agents: `architect`, `code-reviewer`, `security-auditor`,
  `ops-engineer`, `qa-tester` (all with `memory: project`).
- 6 core skills: `sprint-plan`, `build`, `review`, `fix`, `red-team`,
  `capture-lessons`.
- Hooks: `Stop` (test gate), `PostToolUse(Write|Edit)` (linter), `PreToolUse(Bash)`
  (deny-list), `Notification` (desktop alerts).
- Scoped rules: `general.md`, `backend/api.md`, `frontend/components.md`,
  `security/auth.md`.
- Documentation: `docs/WORKFLOW.md` (~960 lines).

  Commit: `b48149d` — *chore: initial commit — Claude Code Workflow Template v3.2*

---

## Pre-extraction history (v0 → v3.1)

These versions existed in the origin project's private history. They are
documented here for traceability but are not present in this public repository.

- **v3.1 (2026-03-18)** — `WORKFLOW.md` updated with refined session discipline
  and context management rules.
- **v3.0 (2026-03-02)** — First version of `docs/WORKFLOW.md`. Workflow
  documented as a coherent system.
- **v1.0 (2026-03-02)** — First executable sprint cycle. 5 agents, 6 skills,
  hooks operational.
- **v0 (2026-02-02 to 2026-02-21)** — Pre-workflow incubation. Manual multi-agent
  approach with 8 ad-hoc agents. Experimentation that informed v1.
