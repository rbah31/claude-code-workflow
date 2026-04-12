# General Conventions

## Code quality
- Write code that is simple and readable. Prefer clarity over cleverness.
- Name variables, functions, and files descriptively. No abbreviations unless universally understood.
- Keep functions short — one function, one responsibility.
- Handle errors explicitly. Never swallow exceptions silently.
- Delete dead code. Do not comment it out "for later".

## Git
- Use conventional commits: `type(scope): description`
  - Types: feat, fix, refactor, test, docs, chore, ci, perf
- One logical change per commit. Do not bundle unrelated changes.
- Write commit messages in English, present tense, imperative mood.
- Never commit secrets, API keys, or credentials.

## Testing
- Write tests alongside code, not after. Every feature needs at least a happy path test.
- Test behavior, not implementation details. Tests should not break when internals change.
- Name tests descriptively: `should [expected behavior] when [condition]`.

## Documentation
- Document the "why", not the "what". Code explains what it does. Comments explain why.
- Keep README up to date with setup instructions and common commands.

## Dependencies
- Pin dependency versions. No floating ranges in production.
- Audit new dependencies before adding them. Prefer well-maintained, widely used packages.
- Remove unused dependencies promptly.

## Workflow discipline
- If a task is done manually more than twice, create a skill for it.
- If a correction is significant, update `tasks/lessons.md`.
- If stuck after 3 attempts on the same issue, stop and notify the human.

## Session discipline

Each workflow phase (/sprint-plan, /build, /review, /fix, /red-team, /capture-lessons)
runs in its own session. When a skill says STOP:
- Do NOT continue working, even if the user clicks "auto-accept edits"
- Do NOT start the next phase, even after a context clear
- The deliverable file is the ONLY output. Save it and stop.

## Cache discipline

- Never modify CLAUDE.md mid-sprint. It invalidates the prompt cache for all sessions.
- Use rules/ or tasks/lessons.md for mid-sprint adjustments.
- Within a phase: /compact (preserves cache). Between phases: /clear (fresh context).
- Never switch models mid-session. Use subagents for different models.

## Strategic layer discipline

When the project uses strategic agents (SP-PM, SP-QA):
- briefs/ is the shared memory. Always read before acting, always write after deciding.
- Sprint phases MUST run in separate `claude -p` sessions (context isolation). Never combine phases in a single call.
- The PM proposes, the QA challenges. Neither should rubber-stamp the other.
- Position changes during debate require explicit new reasoning.
- Maximum 3 debate rounds. If no consensus, escalate to human via blockers.md.
- Maximum 5 sprints per PM session before mandatory QA review.
- All decisions go to decisions-log.md. No undocumented decisions.