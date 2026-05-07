---
name: full-sprint
description: >
  Orchestrates a complete sprint cycle autonomously. Each phase runs as a
  separate claude -p session for context isolation. Use when the
  sprint-directive.md is ready and the sprint should execute end-to-end.
  Also use when the user says "run a full sprint", "execute the sprint",
  "build everything", "autonomous sprint", or "run the cycle".
---

# Full Sprint Execution

You are orchestrating a complete sprint cycle. Each phase runs in an
isolated `claude -p` session for context isolation — the review
MUST NOT have the build context (it biases the review).

**IMPORTANT**: This skill automates the same phase-by-phase workflow as
the manual sprint cycle. Quality comes from context isolation, not from
running everything in one session. Each phase runs via `claude -p
--dangerously-skip-permissions` so all hooks fire (Stop runs tests,
PostToolUse scans secrets, PreToolUse blocks denylisted commands and
destructive git ops).

## Step 1 — Load context

Read `briefs/sprint-directive.md` for the sprint scope and type.
Read `.claude/CLAUDE.md` to get the project name and context.

## Step 2 — Determine sprint number

Find the highest sprint number in `tasks/sprints/` and use N+1.
Create the directory: `tasks/sprints/sprint-XX/`

## Step 3 — Execute phases

For each phase, run a separate `claude -p` session via Bash:

```bash
claude -p --dangerously-skip-permissions \
  "You are working on [project name]. \
   Read .claude/CLAUDE.md for project conventions. \
   Read .claude/skills/[skill]/SKILL.md and follow its instructions exactly. \
   Input: [input file path]. \
   Save output to tasks/sprints/sprint-XX/[output file]. \
   Run tests before declaring done."
```

**Why `claude -p` without `--bare`**: full hook enforcement applies — the
Stop hook runs tests, PostToolUse scans for secrets, PreToolUse blocks
denylisted commands and destructive git operations. The CLAUDE.md, rules,
and skills load automatically, so the agent gets the full project context
without us having to inline everything in the prompt.

The previous v3.x recommendation to use `--bare` for "~10x SDK startup
performance" was retired in v4.0 because the trade-offs (hooks skipped,
API-only auth that breaks Claude Max OAuth, missing CLAUDE.md/rules
auto-load) outweighed the startup gain. The `--dangerously-skip-permissions`
flag alone gives the same non-interactive behavior with all guarantees
preserved.

### Phase sequence

**Phase 1 — Sprint plan**:
- Skill: `.claude/skills/sprint-plan/SKILL.md`
- Input: `briefs/sprint-directive.md`
- Output: `tasks/sprints/sprint-XX/plan.md`

**Phase 2 — Build**:
- Skill: `.claude/skills/build/SKILL.md`
- Input: `tasks/sprints/sprint-XX/plan.md`
- Output: `tasks/sprints/sprint-XX/build-output.md`

**Phase 3 — Review**:
- Skill: `.claude/skills/review/SKILL.md`
- Input: `tasks/sprints/sprint-XX/build-output.md`
- Output: `tasks/sprints/sprint-XX/review-output.md`
- Note: this phase invokes code-reviewer and qa-tester subagents internally

**Phase 4 — Fix**:
- Skill: `.claude/skills/fix/SKILL.md`
- Input: `tasks/sprints/sprint-XX/review-output.md`
- Output: `tasks/sprints/sprint-XX/fix-output.md`

**Phase 5 — Red team** *(security sprint type only)*:
- If sprint type (from sprint-directive.md) is "security":
  - Skill: `.claude/skills/red-team/SKILL.md`
  - Input: `tasks/sprints/sprint-XX/fix-output.md`
  - Output: `tasks/sprints/sprint-XX/redteam-output.md`
- If sprint type is "normal" or "hotfix": skip this phase

**Phase 6 — Capture lessons**:
- Skill: `.claude/skills/capture-lessons/SKILL.md`
- Input: all sprint-XX files
- Output: `tasks/sprints/sprint-XX/retrospective.md` + updated lessons.md, backlog.md

## Step 4 — Verify after each phase

After each `claude -p` call:
1. Verify the expected output file was created
2. If not created → retry ONCE with the same command, then report failure and STOP
3. After review: note if critical issues were found (informational — /fix handles them)
4. After fix: read fix-output.md and check if tests pass
   - If tests fail → report failure and STOP, do not loop

## Step 5 — Post-sprint

After all phases complete:
1. Execute `/update-briefs` to sync shared memory
2. Create a branch and PR with sprint description:
   ```bash
   git checkout -b sprint-XX-[theme]
   git add -A
   git commit -m "feat(sprint-XX): [sprint goal from directive]"
   git push -u origin sprint-XX-[theme]
   ```
3. Report completion with summary

## Channel mode (remote execution)

If invoked via Channel (Telegram/Discord), adapt your output:
- Send progress updates after each phase completes (1-2 lines)
- Send a full summary at the end (5-10 lines)
- End with: "Sprint complete. PR ready for review."
- If a phase fails, notify immediately
- Keep Channel messages concise — the human is likely on a phone

## Gotchas
- Each `claude -p` session is fully isolated. This is intentional — a review without build context is more critical.
- Subagents within each phase (code-reviewer in /review, architect in /sprint-plan) work normally inside `claude -p` sessions.
- If a phase takes too long or errors out, the sprint stops. Do not attempt infinite retries.
- The `--dangerously-skip-permissions` flag is for dev/MVP only. For production, configure permissions in `settings.json` and remove the flag.
- Monitor your own context: if approaching 60%, wrap up and report status.
- The `git add -A` in Step 5 is acceptable here because the sprint workspace should only contain sprint changes. Review the diff before pushing if in doubt.

**STOP. Your deliverable is a completed sprint with all output files and a PR.**
Do NOT start the next sprint. The SP-PM or human decides what's next.
