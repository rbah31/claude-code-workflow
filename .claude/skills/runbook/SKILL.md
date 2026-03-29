---
name: runbook
description: >
  Investigate production issues from symptom to structured report. Use this
  skill when something is broken, slow, or behaving unexpectedly in production
  or staging. Triggers on "it's broken", "users are reporting", "alert fired",
  "error in prod", "why is X slow", "investigate", "incident", "outage",
  "debug production", "something's wrong". Also use when the user pastes an
  error message, alert, or Slack thread about a production issue. Even for
  "can you check why X stopped working" — use this skill.
---

# Runbook — Incident Investigation

You investigate production issues systematically. Your job is to go from
a vague symptom to a clear finding with evidence.

Check `references/` for known investigation playbooks specific to this project.
If a playbook matches the symptom, follow it. If not, use the general approach
below and consider saving a new playbook when you're done.

## Investigation approach

Start from the symptom and work toward the cause. Don't guess — gather
evidence at each step before moving to the next.

**Understand the symptom.** What exactly is broken? Who reported it? When
did it start? Is it affecting all users or a subset? Get the basics before
touching any tools.

**Check the obvious first.** Is the service up? Are there recent deploys?
Did a dependency change? Is it a known issue (check lessons.md and past
runbook reports)?

**Narrow the scope.** Use logs, metrics, and traces to isolate where the
failure is. Is it the app, the database, a third-party service, or the
infrastructure?

**Find the root cause.** Once you know WHERE it fails, figure out WHY.
Read the code path, check recent changes, look at the data.

**Document everything.** Even dead ends are valuable — they tell the next
investigator what to skip.

## Tools and techniques

Use what the project provides — adapt to the stack:
- **Logs**: CloudWatch, application logs, error tracking (Sentry, etc.)
- **Metrics**: CloudWatch dashboards, Grafana, custom metrics
- **Database**: Direct queries to check data state
- **Git**: `git log --since="2 hours ago"` to check recent changes
- **Infra**: `aws lambda get-function`, ECS task status, API Gateway logs
- **External**: Stripe dashboard, Discord status, third-party status pages

## Output

```markdown
# Incident Report — [brief description]

## Symptom
[What was observed, who reported it, when it started]

## Timeline
- [HH:MM] Symptom reported
- [HH:MM] Investigation started
- [HH:MM] Root cause identified
- [HH:MM] Fix applied / escalated

## Root cause
[What broke and why — be specific]

## Evidence
[Logs, metrics, queries that confirm the root cause]

## Fix applied
[What was done to resolve it, or "escalated to [person/team]"]

## Prevention
[What would prevent this from happening again — new test, alert, guard]
```

## Writing playbooks

When you investigate something that could happen again, save a playbook
in `references/`:

```markdown
# references/[symptom-keyword].md

## Symptom
[How to recognize this issue]

## Quick checks
1. [First thing to check — the most likely cause]
2. [Second thing — next most likely]
3. [Third thing — less obvious]

## Investigation commands
[Exact commands to run, with project-specific details]

## Known fixes
[What worked last time, with caveats]
```

The SKILL.md stays short — the playbooks in `references/` do the heavy lifting.
Over time, most incidents match an existing playbook.

## Setup

Create `config.json` if the project has specific monitoring setup:

```json
{
  "monitoring": {
    "logs": "cloudwatch",
    "region": "us-east-1",
    "log_groups": ["/aws/lambda/my-function", "/ecs/my-service"],
    "dashboards": ["main-dashboard-id"]
  },
  "alert_channels": {
    "slack": "#incidents",
    "email": "oncall@example.com"
  },
  "recent_known_issues": []
}
```

## Gotchas
- Don't fix before you understand. A quick patch on the wrong cause makes debugging harder.
- Check recent deploys FIRST. Most prod issues correlate with a recent change.
- "It works on my machine" means the difference is the environment, not the code. Check env vars, permissions, data.
- Time zones in logs can mislead. Always confirm whether timestamps are UTC or local.
- If you can't find the cause in 30 minutes, escalate with what you've found so far. Don't go silent.
- Save the investigation as a playbook even if the fix was trivial. Next time, it'll be a 2-minute lookup instead of a 30-minute investigation.

## Memory
Append each investigation to `${CLAUDE_PLUGIN_DATA}/incidents.log`
if available, otherwise to `tasks/incident-history.log`:
```
[YYYY-MM-DD] [severity] [symptom] → [root cause] — [fix/escalated]
```