# Contributing

Thank you for your interest in contributing to claude-code-workflow.

This workflow is opinionated by design. It reflects two months of running structured AI-assisted development on a real production project. Contributions are welcome, but please understand that the core philosophy (sprint cycle, agent boundaries, hook enforcement, file-based handoff) is non-negotiable.

## What we welcome

- **Bug reports** — Especially around hooks not firing as expected, agents producing inconsistent output, or skills failing silently.
- **New skills** — If you've automated a task that's clearly generic and reusable (not project-specific), open a PR.
- **Documentation improvements** — Typos, clarifications, examples. Go ahead.
- **New language translations** — The current docs are in English. French, Spanish, German, Japanese welcome.
- **Case studies** — Used this workflow on your project? Open a PR to add it to the README's "Built with this workflow" section.

## What we don't accept

- **Wholesale workflow redesigns.** The cycle and agent count are deliberate. If you disagree, fork.
- **Project-specific agents or skills.** Keep your custom agents in your own repo. Only generic, broadly-useful additions belong here.
- **Removing the hooks or relaxing the deny-list.** These are safety mechanisms learned the hard way.

## How to contribute

1. **Open an issue first** describing what you want to change and why. This avoids wasted work on PRs that won't be merged.
2. **Fork and branch** following the convention `feat/short-name` or `fix/short-name`.
3. **Test your change** by cloning the template into a fresh project and running through at least one sprint cycle (`/sprint-plan → /build → /review → /fix → /capture-lessons`).
4. **Document** your change in the PR description: what, why, how it was tested.
5. **Update CHANGELOG.md** with an entry under `## [Unreleased]`.
6. **Submit the PR** and wait for review. Maintainer responds within 7 days during the first weeks post-launch, slower after that.

## Development principles

If your change touches the core workflow:

- **Plan first.** Don't write code without a plan. If you can't articulate the change in `tasks/sprints/sprint-XX/plan.md`, it's not ready.
- **Test on a real scenario.** Spin up a throwaway project and run the workflow end-to-end with your change.
- **Update the docs.** Any change to behavior must be reflected in `docs/WORKFLOW.md`.
- **Don't break the autonomous mode.** Changes that work in manual mode but break the strategic-pm orchestration are rejected.

## Code of Conduct

Be respectful, be patient, be constructive. This is a side project maintained by one person, not a Fortune 500 vendor. Tone matters.

## Questions

For questions that aren't bug reports or feature requests, use [GitHub Discussions](https://github.com/rbah31/claude-code-workflow/discussions).

For private inquiries (consulting, enterprise adoption, partnerships), open a discussion and we'll move to email if needed.
