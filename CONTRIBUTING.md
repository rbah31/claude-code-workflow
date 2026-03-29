# Contributing

Thanks for your interest in improving this workflow template!

## What we welcome

- **New skills** — if you've built a skill that's useful across projects,
  submit it as a PR with a SKILL.md following the existing pattern
  (frontmatter, steps, gotchas, stop)
- **Improvements to existing skills** — especially Gotchas sections,
  which improve with real-world experience
- **New scheduled task prompts** — for the catalog in
  `docs/scheduled-tasks-prompts.md`
- **Bug fixes** — in `verify.sh`, documentation, or skill logic
- **Documentation improvements** — especially real-world usage examples

## What we don't accept

- Project-specific content (your CLAUDE.md, your backlog, your rules)
- Changes to the core sprint cycle without extensive discussion
- Dependencies on specific cloud providers (keep it generic)
- Automated orchestration between phases (human validation is intentional)

## How to contribute

1. Fork the repo
2. Create a branch: `feature/my-improvement`
3. Make your changes
4. Run `bash verify.sh` — all checks must pass
5. Open a PR with a clear description of what and why

## Skill guidelines

If submitting a new skill, follow the pattern from existing skills:

- Frontmatter with pushy description (~100 tokens)
- Clear steps with context (WHY, not just HOW)
- Gotchas section (the most valuable part)
- STOP directive at the end
- Channel mode section for remote execution

## Code of conduct

Be kind, be constructive, be specific.
