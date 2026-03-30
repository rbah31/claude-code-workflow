# References

Engineering insights and best practices that informed this workflow.

## From the Claude Code team at Anthropic

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

### Anthropic Engineering Blog

- **"Building agents with the Claude Agent SDK"**
  Agent loop (gather context, take action, verify work, repeat),
  subagents for parallelism and context isolation, compaction,
  tools as execution building blocks, LLM as judge.
  https://claude.com/blog/building-agents-with-the-claude-agent-sdk

- **"Harness design for long-running application development"**
  Generator/evaluator separation, context resets vs compaction,
  planner necessity, sprint contracts, harness simplification
  as models improve.
  https://www.anthropic.com/engineering/harness-design-long-running-apps

- **"Building effective agents"**
  Foundational patterns for agent design. "Find the simplest
  solution possible, and only increase complexity when needed."
  https://www.anthropic.com/research/building-effective-agents

- **"Effective context engineering for AI agents"**
  Context management strategies for long-running agents.
  https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents

### Claude Code CLI tips (Boris Cherny, Claude Code team)

Source: https://x.com/bcherny (March 2026 thread)

- **`--bare`**: Skip CLAUDE.md/settings/MCP scan for faster SDK startup
  (up to 10x). Use for non-interactive `claude -p` calls where you
  explicitly specify what to load. Useful for automated orchestration.

- **`--add-dir`**: Give Claude access to additional folders beyond the
  working directory. Use when working across multiple repositories or
  when a companion project needs to see another repo.

- **`--agent`**: Launch Claude Code with a custom system prompt and
  tools from .claude/agents/. Run `claude --agent=<name>` to start
  a session as a specific agent. Enables dedicated agent sessions
  (e.g., strategic partner, debugger).

- **`/voice`**: Enable voice input. Hold spacebar to speak instead of
  type. Works in CLI (spacebar), Desktop (voice button), and iOS
  (dictation settings). Useful for end-of-day journals and debriefs.

Documentation: https://code.claude.com/docs/en/cli
Subagents: https://code.claude.com/docs/en/sub-agents

## Claude Code documentation

- Channels (Telegram/Discord): https://code.claude.com/docs/en/channels
- Scheduled tasks: https://code.claude.com/docs/en/scheduled-tasks
- Remote Control: https://code.claude.com/docs/en/remote-control
- Changelog: https://code.claude.com/docs/en/changelog
