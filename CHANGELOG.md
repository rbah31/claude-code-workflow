# Changelog

All notable changes to this workflow are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## Background

This workflow was incubated for two months on a real production project (55+
sprints) before being extracted into this public template on 2026-03-29. The
pre-extraction history (v0 → v3.1) lives in the original private project; the
public history starts at v3.2 with commit `b48149d`.

All commit SHAs below are verifiable in this repository's git history via
`git show <SHA>`.

---

## [4.0.0] — 2026-05-07

Major release. Five months of dogfooding on the proving-ground project surfaced
a recurring class of incidents that the v3.x scaffold did not prevent: agents
overwriting uncommitted work, PMs auto-merging PRs without manual smoke checks,
sparse wrap-ups that hid blockers, auto-route on CI failure paving over
pre-existing debt. v4.0 closes these gaps with deterministic enforcement
(hooks) and explicit boundaries (PM merge ownership, archive convention).

### Added

- **Two new PreToolUse hooks** (`.claude/hooks/`):
  - **`block_wiki_write.py`** — blocks direct agent writes under `wiki/**`
    unless the bypass sentinel `.claude/.wiki-review-active` is present. The
    `/wiki-review` skill is the single legitimate path through the gate.
    The wiki stays human-curated; agents propose via
    `briefs/wiki-proposals/<date>-<slug>.md`.
  - **`protect-uncommitted-hook.py`** — blocks destructive git commands
    (`git checkout -- <path>`, `git restore <path>`, `git reset --hard`,
    `git stash drop|clear`, `git clean -f`, `git rm -f`) when the worktree
    is dirty. Closes the silent-overwrite incident pattern observed in
    auto-mode sessions. Allows safe variants (`git restore --staged`,
    `git stash push|pop`, `git reset --soft|--mixed`) and fail-opens on
    internal errors.

- **`strategic-pm` V2 — merge ownership boundary** (`.claude/agents/strategic-pm.md`):
  - PM stops at `gh pr checks --watch` after a QA verdict approves. The PO
    clicks `gh pr merge`. The PM never executes the merge button.
  - Wrap-up template enriched from sparse to 5 explicit sections, including
    **Pre-S<NEXT> requisites extracted item-by-item** from `qa-review.md` —
    pointer alone is no longer sufficient.
  - CI failure routing distinguishes sprint-introduced regressions
    (auto-route to `/fix`) from pre-existing debt surfaced by CI (propose
    2-3 options to the PO and wait for decision).
  - Persistence rule: PM updates `briefs/project-state.md` after each
    sprint with sprint status, post-merge action checklist, and next-sprint
    readiness (`actionable | blocked-by: [list]`). Next session reads it
    first.
  - New step in "How you work": read `briefs/deployment-topology.md` at
    session start to filter pipeline-covered actions out of the manual
    checklist sent to the PO.

- **`briefs/deployment-topology.template.md` (NEW)** — describes what the
  CI/CD pipeline covers automatically vs what stays manual. Read by the PM
  to build the wrap-up. Each project copies and fills with their actual
  pipeline.

- **Archive convention for sprints and backlog**:
  - **`tasks/backlog-archive.md` (NEW)** — append-only archive for completed
    backlog items. Replaces "delete on completion" with searchable
    archival.
  - **`tasks/sprints/archive/` (NEW)** — folder for sprint folders older
    than the 5 most recent. Not loaded by default in any session.
  - **`/capture-lessons` Step 7** reformulated: "move completed items to
    backlog-archive.md" instead of "remove completed items".
  - **`/capture-lessons` Step 8 (NEW)** — "Archive old sprint folders".
    Procedure: keep 5 most recent active in `tasks/sprints/`, move older
    to `tasks/sprints/archive/`.

- **Cache hygiene + tooling preferences + post-sprint boundary** in
  `.claude/CLAUDE.md`:
  - **Cache hygiene** — stable prefix discipline; auto-compact override
    to 80% (paired with new env var) to avoid silent context-rot past 80%.
  - **Task delegation** — when to use sub-agents (Explore for parallel
    scan, isolation for scoped tasks) vs handle in-line. Self-contained
    briefing rule: objective + expected format + max length.
  - **Preferred tools** — dedicated tools beat the shell (Read > cat,
    Edit > sed, Write > echo). Bash for git/pytest/npm/deployment only.
  - **Post-sprint boundary** — fresh session for the next sprint after
    `/capture-lessons`. Long-lived context lives in `briefs/project-state.md`
    and `tasks/lessons.md`, not in conversation history.

- **Two new env vars** in `.claude/settings.json`:
  - `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=80` — auto-compact at 80% instead of
    the 95% default.
  - `CLAUDE_CODE_DISABLE_1M_CONTEXT=1` — 1M context window disabled,
    paired with the 80% cap to keep fresh sessions cheap and predictable.

- **`docs/MIGRATION-v4.md` (NEW)** — step-by-step upgrade guide for v3.5.x
  users covering pull + conflict resolution, behavioral change explanations
  (PM merge gate, project-state bridge, CI failure routing), hook
  verification commands, and rollback procedure.

- **`/wiki-review` skill (NEW)** — `.claude/skills/wiki-review/SKILL.md`.
  The single legitimate path through the `block_wiki_write.py` gate.
  Walks each proposal accumulated under `briefs/wiki-proposals/` with the
  human (merge / rewrite / discard / defer), creates the
  `.claude/.wiki-review-active` sentinel for the duration of the merge,
  and removes it at end of run. Required for the wiki-first pattern to
  function — without it, the hook blocks all wiki/ writes with no escape.

- **`/fix` skill — investigation-shaped findings cannot be deferred**
  (`.claude/skills/fix/SKILL.md`). New rule in Step 2: a review finding
  that needs a quick investigation to diagnose (a `grep`, a read, a
  5-second check) must be investigated **inside the current fix phase**,
  not deferred as *"need to investigate via claude -p"*. The deferral
  pattern hides Critical findings under the guise of investigation,
  closes the sprint, and ships the bug. Decision rule:
  investigation < 15 min → do it now; investigation ≥ 15 min → escalate
  to the human with explicit scope.

### Changed

- **`/capture-lessons` final STOP message** updated to mention the new
  archive moves (backlog-archive.md and tasks/sprints/archive/).
- **`strategic-pm` "How you work"** step list grows from 9 to 11 to include
  the deployment-topology read and the sprint completion flow.
- **`strategic-pm` "CRITICAL — Session semantics"** clarified that "chain
  phases autonomously" applies during the sprint, NOT after the QA verdict
  (where the PM stops at the merge gate).

### Patterns evaluated post-v4

These two patterns are tracked for potential v4.x integration based on
emerging Anthropic Managed Agents features. They are NOT in v4.0 but are
on our radar:

- **Outcome-driven sprints with rubric grader** — Anthropic Managed Agents
  introduces `define_outcomes` + auto-grader against a rubric. Could
  enrich the `/review` phase with a structured rubric grader in a separate
  context window (eliminating the auto-validation bias).
  Reference: <https://platform.claude.com/docs/en/managed-agents/define-outcomes>

- **Memory consolidation assist** — Anthropic Managed Agents `dreams`
  proposes a draft consolidated memory store from past sessions, which
  the human reviews and adopts or discards. Aligns with our manual
  `/journal` + `/wiki-review` discipline; could become a `/consolidate-memory`
  skill that drafts a new MEMORY.md for arbitration.
  Reference: <https://platform.claude.com/docs/en/managed-agents/dreams>

### Q14 prompt refactor — positive examples

All public agents and the build/fix/full-sprint skills get a positive-form
reformulation of their "What you don't do" sections. The prompt-engineering
rationale: positive instructions ("do X") generalize better than negations
("don't do Y") and reduce ambiguity at the edges where the model has to
decide what falls under "X is forbidden". Each agent now opens its
behavioral section with its role explicitly named (e.g., "Your role —
reviewer, not fixer", "Your auditing posture — pentester, not
box-checker"), then states what to do in active voice.

Files reformulated: `architect`, `code-reviewer`, `qa-tester`,
`security-auditor`, `ops-engineer`, `ops-monitor`, `strategic-qa`,
`build`, `fix`, `full-sprint`. The `strategic-pm` agent received its
equivalent reformulation as part of the V2 refactor (above).

### `--bare` removed from `full-sprint` skill

The `full-sprint` skill previously recommended `claude -p --bare
--dangerously-skip-permissions` for ~10x SDK startup performance. The
flag has been removed because the trade-offs (hooks skipped, API-only
auth that breaks Claude Max OAuth, missing CLAUDE.md/rules auto-load)
outweigh the startup gain — particularly now that v4.0 introduces hooks
that you actively want to fire (`block_wiki_write`, `protect-uncommitted`,
PostToolUse secrets scan).

### Migration

See `docs/MIGRATION-v4.md` for upgrade steps from v3.5.x.

### Origin

Validated on the proving-ground SaaS over Sprints S0-S1 (2026-05-04 to
2026-05-07) before propagation here. The PM merge ownership pattern
specifically addressed an incident on 2026-05-05 where an auto-mode
session ran `git checkout main -- .` and overwrote 5 uncommitted
strategic-pm fixes — that incident is what shaped the
`protect-uncommitted-hook.py` design.

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
  Commit: `2a9b1f2` — *feat: upgrade workflow to v3.5 — marketing layer as PM peer*

- **Anti-sycophancy wiring.** Each strategic agent has explicit "PROPOSER /
  CHALLENGER" personas with rules like "I agree without explanation is
  forbidden". Forces evidence-based debate.
  Commit: `5ddc045` — *feat(agents): wire PM ↔ QA ↔ Marketing anti-sycophancy triangle*

- **Audit + 8 missing items documented.** Comprehensive workflow audit covering
  agent invocation patterns, session discipline, and undocumented behaviors.
  Commit: `638ddfb` — *docs: complete v3.5 audit — 8 missing items documented*

### Changed

- **`/effort high` enabled by default.** Higher reasoning effort for all
  strategic agents. Removed misleading `--bare` flag warnings.
  Commits: `d6e0899` — *docs: add /effort high guidance + reinforce --bare warning*
  and `4a99a26` — *fix(workflow): add effort high by default and remove bare flag*

### Pre-release cleanup

- Pre-publication cleanup: removed all client-specific references, unified
  author attribution, gitignored runtime artifacts.
  Commit: `8f106ac` — *chore: pre-publication cleanup for public GitHub release*

---

## [3.4] — 2026-04-05 — Security hardening

### Added

- **Headless mode security hardening.** Comprehensive deny-list (31 patterns)
  for `PreToolUse(Bash)` blocking destructive commands. Secret scanner hooks
  on `PostToolUse(Write|Edit)` detecting AWS keys, Stripe keys, GitHub tokens,
  PEM blocks. Pre-write block on files containing existing secrets.
  Commit: `111d298` — *feat: upgrade workflow to v3.4 — headless mode security hardening*

- **Reinforced PreToolUse hook.** Additional hardening on the deny-list and
  Bash command interception for autonomous (`--dangerously-skip-permissions`)
  workflows.
  Commit: `135c8a9` — *chore(security): harden deny-list and PreToolUse hook for headless mode*

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

  Commit: `b12d004` — *feat: add v3.3 strategic layer — autonomous sprint orchestration*

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
