# References

Engineering insights and best practices that informed this workflow.

---

## Claude Code documentation

Official references for the mechanisms used in this workflow:

- **Channels** (Telegram/Discord): https://code.claude.com/docs/en/channels
- **Cloud scheduled tasks**: https://code.claude.com/docs/en/web-scheduled-tasks
- **CLI /loop and Desktop scheduled tasks**: https://code.claude.com/docs/en/scheduled-tasks
- **Remote Control**: https://code.claude.com/docs/en/remote-control
- **Subagents**: https://code.claude.com/docs/en/sub-agents
- **Hooks reference**: https://code.claude.com/docs/en/hooks
- **Skills reference**: https://code.claude.com/docs/en/skills
- **Settings & permissions**: https://code.claude.com/docs/en/settings
- **Plan mode**: https://code.claude.com/docs/en/plan-mode
- **CLI reference**: https://code.claude.com/docs/en/cli
- **Changelog**: https://code.claude.com/docs/en/changelog

---

## Anthropic Engineering Blog

Research that directly shaped the workflow architecture:

- **"Building agents with the Claude Agent SDK"**
  Agent loop (gather context, take action, verify work, repeat),
  subagents for parallelism and context isolation, compaction,
  tools as execution building blocks, LLM as judge.
  https://claude.com/blog/building-agents-with-the-claude-agent-sdk

- **"Harness design for long-running application development"**
  Generator/evaluator separation, context resets vs compaction,
  planner necessity, sprint contracts, harness simplification
  as models improve. Directly informed the skill-per-phase design.
  https://www.anthropic.com/engineering/harness-design-long-running-apps

- **"Building effective agents"**
  Foundational patterns for agent design. "Find the simplest
  solution possible, and only increase complexity when needed."
  https://www.anthropic.com/research/building-effective-agents

- **"Effective context engineering for AI agents"**
  Context management strategies for long-running agents.
  https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents

---

## From the Claude Code team at Anthropic

> Note: verify each URL is still accessible before sharing — X/Twitter threads
> can be deleted or go private.

### Thariq Shihipar (@trq212)

- **"Lessons from Building Claude Code: Seeing like an Agent"**
  Progressive disclosure, AskUserQuestion tool design, Todos-to-Tasks
  evolution, search interface design, Guide subagent pattern.
  https://x.com/trq212/status/2027463795355095314

- **"Lessons from Building Claude Code: Prompt Caching Is Everything"**
  System prompt layout for caching, cache-safe compaction, model/tool
  stability, Plan Mode as a tool, defer_loading pattern.
  https://x.com/trq212/status/2024574133011673516

- **"Your Agent should use a File System"**
  File system as state representation, memory via files, planning via
  scratch pads, deep research with subagent file outputs.
  https://x.com/trq212/status/1970243253061783669

- **"Making Playgrounds using Claude Code"**
  Interactive HTML playgrounds for architecture visualization,
  design review, and brainstorming.
  https://x.com/trq212/status/1982869394482139206

- **"Skills best practices"**
  Trigger-focused descriptions, config self-setup, memory pattern,
  lib/ helpers for shared logic, and Gotchas section for edge cases.
  https://x.com/trq212/status/2017024445244924382

### Boris Cherny (Claude Code team)

Source: https://x.com/bcherny (March 2026 thread)

- **`--add-dir`**: Give Claude access to additional folders beyond the
  working directory. Use when working across multiple repositories or
  when a companion project needs to see another repo.

- **`--agent`**: Launch Claude Code with a custom system prompt and
  tools from `.claude/agents/`. Run `claude --agent=<name>` to start
  a session as a specific agent. Enables dedicated agent sessions
  (e.g., strategic partner, debugger).

- **`/voice`**: Enable voice input. Hold spacebar to speak instead of
  type. Works in CLI (spacebar), Desktop (voice button), and iOS
  (dictation settings). Useful for end-of-day journals and debriefs.

- **`--bare`**: Skips CLAUDE.md/settings/MCP scan for faster SDK startup
  (up to 10x). Trade-off: API-only (no OAuth/Max support), skips all
  hooks, rules, and project configuration.
  **This workflow does not use `--bare` in manual sessions** — it causes
  auth failures on Max plans and defeats hook enforcement. Exception: the
  `/full-sprint` skill uses it intentionally for performance with
  documented trade-offs (see `.claude/skills/full-sprint/SKILL.md`).

---

## Research informing this workflow

### Emotion Concepts and Functional Emotions (Anthropic, April 2026)

- **Paper**: https://transformer-circuits.pub/2026/emotions/index.html
- **Key finding**: Claude has internal representations of emotion concepts
  that causally influence outputs, including alignment-relevant behaviors
  (sycophancy, reward hacking). Called "functional emotions."
- **Relevance for the workflow**: Supports the importance of calm,
  respectful agent prompts and fresh context between phases (emotional
  states accumulate in context). Potential future optimization: emotionally
  calibrated prompts for better reasoning quality.
- **Status**: Reference only — no workflow changes yet. Revisit when data
  is available to compare prompt styles.

---

## Skills from the community

Third-party skills included in this repo (see `NOTICE` for full license texts):

- **frontend-slides** — HTML presentation skill by [@zarazhangrui](https://github.com/zarazhangrui).
  Create animation-rich slides from scratch or convert PowerPoint files. MIT License.
  https://github.com/zarazhangrui/frontend-slides

---

## Tools

Tools used alongside this workflow:

- **ccusage** — cost tracking for Claude Code sessions. Used to validate
  cost figures in this repo's documentation.
  https://github.com/ryoppippi/ccusage

- **Amphetamine** — prevents Mac sleep during remote operations (closed-lid
  or screen-locked). Free, Mac App Store. Required for the remote ops
  setup described in `docs/mac-persistent-setup.md`.
  https://apps.apple.com/app/amphetamine/id937984704
