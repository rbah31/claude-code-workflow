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

## Available agents

5 universal agents in `.claude/agents/`: architect, code-reviewer, security-auditor, ops-engineer, qa-tester.
2 optional slots for project-specific agents. Only create when a real need emerges after 2-3 sprints.

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
