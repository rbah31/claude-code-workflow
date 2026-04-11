# briefs/

Shared memory between the strategic agents (PM, QA, marketing-strategist).
All agents read before acting, write after deciding.

## Files and their purpose

| File | Owner | Purpose |
|------|-------|---------|
| `direction.md` | Human / PM | Product vision, milestones, strategic goals |
| `project-state.md` | PM | Current sprint status, what's done, what's in progress |
| `sprint-directive.md` | Human / PM | Instructions for the next sprint to execute |
| `qa-review.md` | QA agent | Sprint review: what passed, what failed, blockers |
| `decisions-log.md` | PM + QA | All architectural and product decisions with rationale |
| `blockers.md` | Any agent | Escalations requiring human input |
| `marketing-context.md` | marketing-strategist | Positioning, ICP, tone of voice, competitive landscape |
| `marketing-directive.md` | Human / PM | What marketing should focus on this sprint |
| `marketing-sync.md` | marketing-strategist | Output of `/marketing-sync` runs |
| `user-feedback.md` | Human / marketing | Raw user feedback, support tickets, NPS signals |
| `weekly-debrief.md` | PM | Weekly summary for async stakeholders |

## Initialization order

1. Fill `direction.md` — your product vision and milestones (required before first sprint)
2. Run `/marketing-sync` (Mode 4) — generates `marketing-context.md` from your vision
3. Fill `sprint-directive.md` — what to build in sprint 1
4. Let agents populate the rest automatically during sprint execution

## Template files

Each `*.template.md` file is an empty scaffold. Copy and rename to get started:

```bash
cp briefs/direction.template.md briefs/direction.md
```

## Reference

- Strategic PM agent: `.claude/agents/strategic-pm.md`
- QA agent: `.claude/agents/qa-tester.md`
- Marketing agent: `.claude/agents/marketing-strategist.md`
- Workflow overview: `docs/WORKFLOW.md` § Strategic Layer
