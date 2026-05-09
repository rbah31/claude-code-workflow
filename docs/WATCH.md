# WATCH — Feed

> A reverse-chronological feed of everything we're tracking: Anthropic releases,
> Claude Code team posts, research, community resources, and the occasional
> unrelated-but-interesting find.
>
> New entries go at the top. Nothing gets deleted — past entries show how our
> thinking evolved.
>
> **For canonical sources we actually use** (papers, docs, team posts shaping
> the workflow): see [REFERENCES.md](./REFERENCES.md).
> **This file is the living log** — what we've seen, what we think about it,
> what's next.

---

## Legend

Each entry is tagged to make scanning fast:

- 🆕 **New** — just surfaced, not yet evaluated
- 👀 **Watching** — interesting, no decision yet
- 🧪 **Evaluating** — under active testing
- ✅ **Integrated** — now part of the workflow
- ❌ **Rejected** — evaluated and passed, with a documented reason
- 💡 **Inspiration** — informed our thinking, not a direct adoption
- 🛠 **Tool** — something we use alongside the workflow

---

## 2026

### 2026-04-10 — 🧪 Ultraplan (Claude Code)

Cloud-based planning with inline review. May enhance or replace `/sprint-plan`
for complex features. Auto-creates a default cloud environment if none is set
up. To evaluate in a future sprint.

Source: [Claude Code changelog](https://code.claude.com/docs/en/changelog)

---

### 2026-04-09 — 🧪 Advisor tool (Claude Code)

Sonnet executor + Opus advisor in a single API call. Anthropic reports
+2.7 pp on SWE-bench at -11.9% cost. If it holds up, could replace our
per-agent model routing pattern (where we manually assign Opus to
`architect`/`security-auditor` and Sonnet elsewhere).

Watching for: stability reports from the community, real-world cost confirmation.

---

### 2026-04-09 — 🧪 Monitor tool (Claude Code v2.1.98)

Streaming events from background scripts. Directly relevant to the
"PM agent polls with `test -f`" anti-pattern we hit in sprint 53 —
Monitor lets you subscribe to events instead of polling. Could replace
that loop.

Also shipped in the same release: subprocess sandboxing on Linux with
PID namespace isolation, `CLAUDE_CODE_PERFORCE_MODE` (not relevant for us),
Vertex AI setup wizard.

Source: [Claude Code v2.1.98 release notes](https://code.claude.com/docs/en/changelog)

---

### 2026-04-08 — 🧪 Managed Agents (beta) (Anthropic)

A fully managed agent harness with secure sandboxing, built-in tools, and
server-sent event streaming. Create agents, configure containers, and run
sessions through the API. Requires `managed-agents-2026-04-01` beta header.

This is effectively the productized version of what this workflow does by
hand. We're the artisanal equivalent. Watching to see whether the managed
version covers our autonomous-sprint use case, or whether the artisanal
control we have (rules, hooks, explicit agents) is still the right trade-off.

Source: Anthropic documentation

---

### 2026-04 (ongoing) — ✅ Prompt caching on all long-running sessions

Not a new feature, but worth calling out: our sprints show a **95.5% cache
read ratio** across 2.18B total tokens. The cache layout matters — stable
CLAUDE.md + deferred-loading skills is what makes this work. The reason
per-sprint cost stays predictable.

This aligns with Thariq's thread
[Prompt Caching Is Everything](https://x.com/trq212/status/2024574133011673516).

---

### 2026-04 — 🛠 ccusage (Ryo Ogawa)

Every cost figure in this repo's documentation is validated via `ccusage`.
Lightweight CLI that parses Claude Code usage logs and produces breakdowns
by day/model. If you're publishing cost numbers about Claude Code, this is
the tool.

Source: [github.com/ryoppippi/ccusage](https://github.com/ryoppippi/ccusage)

---

### 2026-04 — 💡 MindStudio — Claude Code Q1 2026 Update Roundup

Good synthesis of Remote Control, Dispatch, Channels, Computer Use, Auto
Mode, AutoDream. Useful for seeing the bigger picture beyond individual
release notes.

Source: [mindstudio.ai/blog/claude-code-q1-2026-update-roundup](https://www.mindstudio.ai/blog/claude-code-q1-2026-update-roundup)

---

### 2026-04 — 💡 MindStudio — Loop vs Scheduled Tasks

Decision framework comparing `/loop` (session-scoped, reactive) vs cloud
scheduled tasks (persistent, infrastructure-managed). Informed the slot
strategy in our [scheduled-tasks-prompts.md](./scheduled-tasks-prompts.md).

Source: [mindstudio.ai/blog/claude-code-loop-vs-scheduled-tasks](https://www.mindstudio.ai/blog/claude-code-loop-vs-scheduled-tasks)

---

### 2026-03 — 👀 Claude Mythos / Capybara (early access)

Drafts circulating for a tier above Opus — higher scores on coding,
academic reasoning, and cybersecurity, at a higher cost. Not publicly
available yet. When it ships, candidates for upgrade: `architect` and
`security-auditor`. Watching.

---

### 2026-03 — 💡 Boris Cherny — CLI tips thread (tips 12-15)

From [@bcherny](https://x.com/bcherny):

- **`--add-dir`** — give Claude access to additional folders beyond the
  working directory. Useful for multi-repo work.
- **`--agent=<name>`** — launch Claude as a specific agent from
  `.claude/agents/`. We use this pattern (`claude --agent=strategic-pm`).
- **`/voice`** — voice input. Hold spacebar in CLI. Good for end-of-day
  debriefs.
- **`--bare`** — skip CLAUDE.md/settings/MCP scan for 10x faster SDK
  startup. **❌ Rejected for this workflow:** breaks auth on Max plans
  and skips the hooks/rules that make the workflow safe. See the
  trade-off note in REFERENCES.md.

---

### 2026-03 — 💡 Thariq Shihipar — 5 essential threads

The single best public source on Claude Code's internal design principles.

| Thread | Topic | What we took from it |
|--------|-------|----------------------|
| [1970243253061783669](https://x.com/trq212/status/1970243253061783669) | "Your Agent should use a File System" | File-based handoff between sprint phases (`plan.md` → `build-output.md` → ...) |
| [1982869394482139206](https://x.com/trq212/status/1982869394482139206) | "Making Playgrounds using Claude Code" | Interactive HTML playgrounds for design review. Candidate for a future skill. |
| [2017024445244924382](https://x.com/trq212/status/2017024445244924382) | Skills best practices | Trigger-focused descriptions, config self-setup, `${CLAUDE_PLUGIN_DATA}` memory pattern, `lib/` helpers, Gotchas section. Shaped our 19 skills. |
| [2024574133011673516](https://x.com/trq212/status/2024574133011673516) | "Prompt Caching Is Everything" | Why our CLAUDE.md is stable and small. `defer_loading` pattern. |
| [2027463795355095314](https://x.com/trq212/status/2027463795355095314) | "Seeing like an Agent" | Progressive disclosure, AskUserQuestion, Todos-to-Tasks, Guide subagent |

---

### 2026-03 — 💡 Thariq on scheduled tasks

Examples from Thariq: checking error logs every few hours with Claude Code
auto-creating PRs for fixable bugs. Boris Cherny added: auto-monitoring PRs
with self-fixing, morning Slack summaries. These informed our own scheduled
tasks catalog.

Source: The Decoder coverage of the scheduled tasks launch (March 2026)

---

### 2026-02 — ✅ Remote Control (Anthropic)

Research preview announced by
[Noah Zweben](https://x.com/noahzweben/status/2035122989533163971),
relayed by Boris Cherny. Start local sessions from the terminal, continue
them from mobile via `/remote-control`.

**Integrated as primary remote ops tool.** Replaced our tmux + watchdog
setup. See [mac-persistent-setup.md](./mac-persistent-setup.md). Enables a pattern
our team uses daily: launching a sprint from the desk, observing and
steering it from the phone.

Source: [code.claude.com/docs/en/remote-control](https://code.claude.com/docs/en/remote-control)

---

### 2026-02 — ✅ Channels (Telegram/Discord plugin)

Alternative for teams already living in chat. Install with the Channels
plugin. Kept as **secondary** option — Remote Control is more complete.
Useful if you want sprint updates pushed to a chat and already use
Telegram/Discord for other notifications.

Source: [code.claude.com/docs/en/channels](https://code.claude.com/docs/en/channels)

---

### 2026-02 — ❌ Auto Mode / AutoDream

Auto Mode removes confirmation prompts. **Rejected**: incompatible with
our "authority retained" security posture. The whole point of the hooks
and the deny-list is that Claude doesn't execute destructive actions
without explicit authorization.

AutoDream runs a full autonomous planning loop. **Rejected for the
default cycle**: overkill for focused sprints, conflicts with the
explicit phase-by-phase structure. Narrow use cases exist.

---

### 2026-02 — ❌ Computer Use

Browser/GUI automation. **Rejected**: out of scope for this workflow.
Terminal-first is the design choice. GUI automation is a different tool
for a different purpose (UI testing, scraping, accessibility).

---

### 2026-02 — ✅ Anthropic Skills — complete guide

The canonical Anthropic PDF on skill design: YAML frontmatter, progressive
disclosure, triggering tests, MCP integration patterns, distribution.
Read in full before designing our 19 skills.

Source: [https://code.claude.com/docs/en/overview](https://code.claude.com/docs/en/docs/agents-and-tools/agent-skills/overview)

---

### 2026-02 — 💡 Boris Cherny — CLAUDE.md best practices (screenshot)

Early reference screenshot circulated in February: Workflow Orchestration,
Task Management, Core Principles, Plan Mode Default, Subagent Strategy,
Self-Improvement Loop, Verification Before Done. Shaped the original
structure of our CLAUDE.md template.

---

### 2026 — 💡 Emotion Concepts and Functional Emotions (Anthropic research)

Claude has internal representations of emotion concepts that causally
influence outputs, including alignment-relevant behaviors (sycophancy,
reward hacking). Called "functional emotions".

**No direct workflow changes**, but supports two intuitions we already had:
calm and respectful agent prompts produce better reasoning; fresh context
between phases matters (emotional states accumulate in context).
Revisit when comparison data is available.

Source: [transformer-circuits.pub/2026/emotions](https://transformer-circuits.pub/2026/emotions/index.html)

---

## Ongoing / undated

### 💡 Andrej Karpathy — 4 principles of AI-assisted coding

- Think Before Coding
- Simplicity First
- Surgical Changes
- Goal-Driven Execution

Compatible with our 8-principle framework. The overlap is intentional.

Source: [x.com/karpathy/status/2015883857489522876](https://x.com/karpathy/status/2015883857489522876)

---

### 💡 Forrest Chang — andrej-karpathy-skills

Karpathy's 4 principles turned into Claude Code skills. 250+ stars in days.
Different flavor from our cycle (principles-as-skills vs cycle-as-skills)
but the same spirit. Worth browsing.

Search on GitHub: `andrej-karpathy-skills`

---

### 🛠 Amphetamine (macOS)

Keeps the Mac awake without system modifications. Free on the Mac App
Store. Reversible in 2 minutes (quit the app). See
[mac-persistent-setup.md](./mac-persistent-setup.md).

---

### 🛠 Release notes aggregators

When the official Claude Code changelog isn't convenient:

- [ClaudeLog](https://claudelog.com/faqs/claude-code-release-notes) — community commentary
- [ClaudeFast](https://claudefa.st/blog/guide/changelog) — complete changelog since v0.2
- [Releasebot](https://releasebot.io/updates/anthropic) — daily aggregator, Claude Code tab
- [ClaudeWorld](https://claude-world.com) — article-style release coverage
- [The Decoder](https://the-decoder.com) — tech news with solid Claude Code coverage

---

### 💡 Community repos worth browsing

- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) — curated list
- [Jamie-BitFlight/claude_skills](https://github.com/Jamie-BitFlight/claude_skills) — reference skills library

---

## How to add an entry

1. Put it at the top of the appropriate year section.
2. Use the format: `### YYYY-MM-DD — [tag] Title`.
3. 1-3 sentences. Link to the source. If it's relevant to the workflow,
   say how — if it's not, that's fine too, this is a feed, not a manifesto.
4. Commit with `docs(watch): add [title]`.

If a feature moves from 👀 to 🧪 to ✅/❌, don't edit the past entry —
add a new entry at today's date noting the decision. The history matters.