# Security Policy

## Scope

This repository is a **documentation and configuration template** for Claude Code. It contains markdown files, JSON configuration, and shell scripts. It does not ship executable application code, bundled dependencies, or runtime binaries.

The security surface is therefore limited to:

- Hook configurations in `.claude/settings.json` (executed by Claude Code on the user's machine)
- Shell snippets in documentation (copy-pasted by users)
- Rules and instructions that shape how Claude operates on a user's codebase

## Reporting a vulnerability

If you find a security issue in this repository, please:

1. **Open a GitHub issue** with the label `security`
2. Describe the issue clearly: what you found, where, and what an attacker could do with it
3. If the issue is sensitive enough that public disclosure would cause harm before a fix is available, mention that in the issue title (`[SENSITIVE]`) and a maintainer will switch to private discussion

For a template repository like this one, most issues can be discussed openly. The severe cases (where public disclosure is dangerous) are rare but possible — for example, a hook pattern that bypasses the deny-list in a non-obvious way.

## What counts as a security issue here

- A hook that fails to block a dangerous command it claims to block
- A rule or agent instruction that could be exploited to execute unintended code
- A documentation example that leaks secrets or demonstrates an unsafe pattern without warning
- A `.claude/settings.json` configuration that grants excessive permissions by default

## What does not count

- "Claude could make mistakes" — Claude Code is an LLM-based tool, mistakes are inherent. This repository provides structure to reduce them, not eliminate them.
- "A user could misuse this workflow" — misuse of documentation is not a security vulnerability.
- "The deny-list is not exhaustive" — it never will be. It covers the most dangerous patterns; users must still review commands before approving them.

## Response time

This is a solo-maintained project. Response target: **within 7 days** for issues labeled `security`. Severe issues get prioritized, everything else fits into the regular workflow.

## Defense architecture

For a detailed view of how this workflow defends against common risks (secret leakage, destructive commands, prompt injection), see [docs/SECURITY.md](docs/SECURITY.md).