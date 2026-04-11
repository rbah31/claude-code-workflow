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
- Cross-review mandatory: A never reviews their own code

## Architecture

[3-5 lines describing high-level architecture. E.g.:]
[- Monorepo with backend/ and frontend/ packages]
[- REST API, auth via JWT, data in PostgreSQL]
[- Serverless deployment on AWS]

## Workflow

The sprint cycle is encoded in skills. Invoke and validate, don't micro-manage.

- `/sprint-plan` → `/build` → `/review` → `/fix` → `/red-team` → `/capture-lessons`
- Sprint types: hotfix (build → manual deploy or CI), normal (no red-team), security (full cycle)
- Handoff between phases via `tasks/sprints/sprint-XX/`
- Knowledge capital: `tasks/lessons.md` read at the start of each phase

**Une phase = une session CLI isolée.** Chaque phase tourne dans son propre `claude -p` pour éviter la pollution de contexte. C'est une isolation **technique**, pas une porte de validation humaine.

- Mode manuel : tu invoques `/sprint-plan`, valides le résultat, puis ouvres une nouvelle session pour `/build`.
- Mode autonome (avec strategic-pm) : le PM enchaîne automatiquement toutes les phases en lançant un `claude -p` distinct pour chacune. Aucune intervention PO entre phases.

Le PO n'intervient qu'en début de sprint (briefing) et en fin de sprint (review PR).

Marketing flow (runs in parallel with dev, not sequentially):
- Post-sprint: `/marketing-sync` after `/capture-lessons` — marketing adapts to what shipped
- User feedback: add to `briefs/user-feedback.md` → `/marketing-sync` — PM gets product signal
- Pre-sprint: `/marketing-sync` (Mode 3) — marketing flags which backlog items have highest user demand
- PM ↔ marketing communicate via `briefs/` (marketing-context, marketing-directive, user-feedback)

## Available agents

5 universal agents in `.claude/agents/`: architect, code-reviewer, security-auditor, ops-engineer, qa-tester.
1 marketing agent: `marketing-strategist` — peer of the PM, owns market direction (positioning, copy, SEO, CRO, user feedback). Uses the `marketingskills` community plugin.
1 optional slot for a project-specific agent. Only create when a real need emerges after 2-3 sprints.

## Rules

Detailed conventions in `.claude/rules/`, scoped by path:
- `rules/general.md` — global conventions
- `rules/backend/` — backend conventions
- `rules/frontend/` — frontend conventions
- `rules/security/` — security conventions

## Reflexes

- If a task is done > 2 times manually → create a skill with `/skill-creator`
- If context exceeds ~60% → `/compact` or new session
- If stuck → notify the human, don't spin in circles
- If significant correction → update `tasks/lessons.md`
- Always read `tasks/lessons.md` at the start of each phase (encoded in skills)
- Pour les tâches complexes (multi-fichiers, debugging, architecture) : utiliser `/effort high`. Le mode par défaut peut être insuffisant et cause un comportement edit-first au lieu de research-first.
