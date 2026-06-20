# [PROJECT_NAME]

> [One-sentence description of the product and its value]

## Vision

[2-3 sentences max. What problem we solve, for whom, how.]

## Tech stack

- **Backend**: [e.g. Node.js / TypeScript, Express, PostgreSQL]
- **Frontend**: [e.g. React, Next.js, Tailwind CSS]
- **Infra**: [e.g. AWS Lambda, DynamoDB, CloudFront]
- **CI/CD**: [e.g. GitHub Actions]
- **Tests**: [e.g. Vitest, Playwright]

## Critical conventions

- Code language: [English / your language]
- Commit language: [e.g. English, conventional commits format]
- Main branch: `main`
- Branch pattern: `feature/xxx`, `fix/xxx`, `hotfix/xxx`
- Before declaring "done": tests MUST pass (enforced by Stop hook)
- Reviewer ≠ author: in team settings, code is reviewed by someone else. In solo settings, use a fresh session or the `strategic-qa` agent for an independent review.

## Architecture

[3-5 lines describing high-level architecture. E.g.:]
[- Monorepo with backend/ and frontend/ packages]
[- REST API, auth via JWT, data in PostgreSQL]
[- Serverless deployment on AWS]

## Workflow

The sprint cycle is encoded in skills. Invoke and validate, don't micro-manage.

- `/sprint-plan` → `/build` → `/review` → `/fix` → `/red-team` → `/capture-lessons`
- Sprint types: hotfix (build → deploy), normal (no red-team), security (full cycle)
- **One phase = one isolated `claude -p` session.** Technical isolation, not a human approval gate.
- In autonomous mode (`strategic-pm`), the PM chains all phases without PO intervention.
- Handoff between phases: `tasks/sprints/sprint-XX/` files
- Knowledge capital: `tasks/lessons.md` read at the start of each phase

Marketing runs in parallel (not sequential). PM ↔ marketing communicate via `briefs/`.
Full details: `docs/WORKFLOW.md`.

## Available agents

**5 universal** (use from sprint 1): `architect`, `code-reviewer`, `security-auditor`, `ops-engineer`, `qa-tester`

**3 strategic/ops** (activate after 3+ successful manual sprints):
- `strategic-pm` — orchestrates sprint phases autonomously via `claude -p`
- `strategic-qa` — independently challenges PM decisions, writes `briefs/qa-review.md`
- `ops-monitor` — first responder for monitoring triage

**1 marketing**: `marketing-strategist` — peer of the PM, owns market direction

**1 optional slot**: project-specific agent. Only when a real need emerges after 2-3 sprints.

## Rules

Detailed conventions in `.claude/rules/`, scoped by path:
- `rules/general.md` — global conventions
- `rules/backend/` — backend conventions
- `rules/frontend/` — frontend conventions
- `rules/security/` — security conventions

## Remote operations (optional)

Sessions can be operated from your phone via the Channels plugin (Telegram/Discord).
Requires the Mac to stay awake — see `docs/mac-persistent-setup.md`.

## Stance on tooling

This workflow evolves with Claude Code's capabilities. When a new Anthropic feature
arrives, evaluate if it simplifies what we've built manually. If yes, migrate. If no,
document why in `docs/REFERENCES.md`. See `docs/WORKFLOW.md §6` for current mechanism decisions.

## Cache hygiene

The Anthropic prompt cache (1h TTL on this session) relies on a stable prefix loaded at session start. To maximize hit rate:

- **Lock at session start**: load CLAUDE.md and stable reference files (architecture, conventions, gotchas) first — treat them as the stable prefix. Keep them stable during the session to preserve cache hits.
- **Stable prefix wins**: load reference material early; files in active rewrite (mid-edit working files) come later, outside the initial prefix.
- **Approaching context saturation**: prefer opening a fresh session or running `/compact` manually. Fresh sessions perform better than saturated ones (context rot starts at 40-60%, severe past 80%). Auto-compact is set to 80% via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` to avoid silent degradation.

## Task delegation

Use sub-agents (Agent tool) where they add real value:

- **Delegate to sub-agents** for: large parallel exploration (Explore agent), well-isolated scoped tasks, repo-wide search, protection of the main context from voluminous results.
- **Handle in-line** for: micro-tasks (editing a known file, reading a precise file), tasks needing the live conversation context, uncertain scope. In-line keeps the conversation context coherent.
- **Brief sub-agents self-contained**: objective, minimal context, expected return format, max length ("report under 200 words"). Sub-agents didn't see the conversation — they deserve explicit framing.
- **Read results, not just summaries**: sub-agents report what they intended to do; reading the result catches divergence from what they actually did.

Note: structured agents (`strategic-pm`, `code-reviewer`, etc.) follow their own invocation rules. This block covers generic sub-agent tool usage, not orchestrated sprints.

## Preferred tools

Dedicated tools beat the shell: permission tracking, no escaping cost, structured output. Bash is the right tool for operations no specialized tool covers.

**For each operation, the dedicated tool**:

- **Read a file** → `Read` (line numbers, beats `cat`/`head`/`tail`)
- **Modify a file** → `Edit` (string-validated, requires Read first; safer than `sed`/`awk` which can break silently)
- **Create a file** → `Write` (atomic, beats `echo >` / `cat <<EOF`)
- **Search text** → `Grep` (structured output, beats `grep | xargs`)
- **Search files by pattern** → `Glob` (beats `find` via Bash)
- **Fetch a URL** → `WebFetch` (beats `curl` via Bash)
- **Communication** → direct output (beats `echo` / `printf`)
- **Bash** → git, pytest, npm, deployment, shell-only operations

**Advanced tools to leverage**:

- **`Agent` with `subagent_type=Explore`**: large parallel repo exploration. Protects the main context from voluminous results. Ideal for "where is X defined", "who calls Y across the codebase".
- **Parallelization**: independent tool calls (non-dependent reads/searches) belong in the same message. Sequence with explicit chaining when calls depend on each other.

## Post-sprint boundary

After `/capture-lessons` completes, the sprint is **done**. The next session is a fresh start:

- **Do not chain** another `/sprint-plan` from the same session. Open a new `claude` session for the next sprint to get a clean cache and a focused context window.
- **Read `tasks/lessons.md`** at the start of each phase — the skill enforces this; the lesson is that fresh sessions perform better than continued ones.
- **Long-lived context** belongs in `briefs/project-state.md` (state) and `tasks/lessons.md` (patterns), not in the conversation history.

## Reflexes

- If a task is done > 2 times manually → create a skill with `/skill-creator`
- If context exceeds ~60% → `/compact` or new session
- If stuck → notify the human, don't spin in circles
- If significant correction → update `tasks/lessons.md`
- Always read `tasks/lessons.md` at the start of each phase (encoded in skills)
- **Effort (Opus 4.8)**: xhigh is the default for agentic work (multi-file, debugging, architecture, orchestration) — it's the Claude Code default, keep it. `high` is the floor for known mechanical tasks, not the target. When a session spins, raise the effort (`/effort xhigh`) before adding instructions — under-effort causes edit-first instead of research-first behavior.
