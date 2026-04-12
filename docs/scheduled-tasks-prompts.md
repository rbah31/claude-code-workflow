# Scheduled Tasks — Catalog

Scheduled tasks run passively alongside the sprint cycle — they don't replace any
workflow phase. They monitor, alert, and do housekeeping between sprints.
For workflow context: see `docs/WORKFLOW.md §8`.

## Which type to use

| Need | Type | How |
|------|------|-----|
| Runs without laptop, repo access only | Cloud | `/schedule` in CLI or [claude.ai/code/scheduled](https://claude.ai/code/scheduled) |
| Needs local credentials (AWS, GCP) or MCP connectors (Slack, Gmail, Calendar) | Desktop | Schedule tab in Claude Desktop |
| Watch something for the next hour | Session | `/loop` in Claude Code CLI |

Cloud jobs commit results to `monitoring/`. Desktop jobs write locally
and push. Both converge in the repo via git.

---

> **Minimum intervals:** Cloud = 1 hour. Desktop = 1 minute. `/loop` = 1 minute. Cron expressions firing more frequently than the minimum are rejected.

### Slot strategy

> Cloud agent slot limits vary by plan and may change. Verify your current
> quota at [claude.ai/settings](https://claude.ai/settings) or in the
> Claude Code scheduled tasks UI. The example below assumes 3 slots.

Prioritize cloud slots for the most critical repo-only tasks:

| Priority | Slot | Recommended task |
|----------|------|-----------------|
| 1 | Cloud | Security scan (dependency audit) — daily |
| 2 | Cloud | Daily brief (aggregates all monitoring) — daily |
| 3 | Cloud | Weekly project health (backlog + docs + retro) — weekly |

Tasks needing local credentials (AWS, GCP, Stripe CLI) or MCP connectors
(Slack, Gmail) go to Desktop scheduled tasks.

If you have fewer than 3 critical repo-only tasks, use remaining cloud
slots for test-health or any other repo-only automation.

The weekly-project-health task is a fusion pattern: it combines backlog
hygiene, docs drift, and weekly retro into a single run to save a slot.
Use this pattern when slot-constrained.

---

## What NOT to schedule

- Sprint phases (/build, /review, /fix) — these need human validation
- Red team audits — these need human judgment on scope
- Anything involving payments, refunds, or user data mutations
- Content publishing or social media posting
- Decisions that affect product direction

---

## Cloud agents — repo access only

> Cloud scheduled tasks are created via `/schedule` in the CLI (also `/schedule list`, `/schedule update`, `/schedule run`) or at [claude.ai/code/scheduled](https://claude.ai/code/scheduled). See the [official docs](https://code.claude.com/docs/en/web-scheduled-tasks).

These run on Anthropic's infrastructure. Fresh git checkout each run.
No local credentials, no local services. Can commit and push.

> **Branch safety:** By default, cloud tasks can only push to `claude/`-prefixed branches. Enable "Allow unrestricted branch pushes" per-repository in the scheduled tasks settings if a task needs to push elsewhere.

### dependency-watch

**Frequency:** Daily
**Model:** Sonnet
**What it does:** Scans dependencies for known CVEs, checks if vulnerable
functions are actually used in the codebase, classifies by real exposure.
**Output:** `monitoring/dependency-watch-latest.md` + alerts if critical.

Prompt:

> You are a dependency security auditor for this project.
>
> 1. Identify the package manager (pip, npm, pnpm, cargo, etc.) and
>    install the appropriate audit tool if needed
> 2. Run the audit tool in JSON format on all dependency files
> 3. For each High or Critical CVE: grep the codebase to check if the
>    vulnerable package/function is actually used and if the code path
>    is externally reachable (API endpoints, handlers, webhooks)
> 4. Classify: CRITICAL PROJECT (used + reachable), ATTENTION (used +
>    internal), INFO (present but unused), IGNORE (low or unused)
> 5. Write report to monitoring/dependency-watch-latest.md with:
>    summary, findings (CRITICAL and ATTENTION only), full scan stats,
>    scan metadata (tool version, date, commit SHA)
> 6. If CRITICAL PROJECT found, also save to monitoring/alerts/cve-[date].md
> 7. If report changed, commit and push:
>    chore(monitoring): update dependency audit report
>    Only commit files under monitoring/
>
> If zero vulnerabilities, still update with clean bill of health + date.

---

### backlog-hygiene

**Frequency:** Weekly (Monday)
**Model:** Sonnet
**What it does:** Audits the backlog for stale items, missing metadata,
duplicates, and orphaned references.
**Output:** `monitoring/backlog-hygiene-latest.md`

Prompt:

> You are a backlog hygiene auditor for this project.
>
> 1. Read tasks/backlog.md
> 2. Check for issues:
>    - Items without complexity estimate (S/M/L)
>    - Items without source
>    - Items in "High priority" for more than 3 sprints without pickup
>    - Duplicate or near-duplicate items
>    - Items referencing code/files that no longer exist (grep to verify)
> 3. Read the last 3 sprint retrospectives in tasks/sprints/ to check
>    if completed items were properly removed from backlog
> 4. Write report to monitoring/backlog-hygiene-latest.md:
>    summary, stale items, missing metadata, orphaned references,
>    re-prioritization suggestions
> 5. If report changed, commit and push:
>    chore(monitoring): update backlog hygiene report
>    Only commit files under monitoring/

---

### docs-drift

**Frequency:** Weekly (Wednesday)
**Model:** Haiku
**What it does:** Detects documentation that has drifted from the code.
**Output:** `monitoring/docs-drift-latest.md`

Prompt:

> You are a documentation drift detector for this project.
>
> 1. Read README.md, docs/, and .claude/CLAUDE.md
> 2. Compare documented info against actual code:
>    - Are documented commands/features still in the code?
>    - Are there new features not mentioned in docs?
>    - Do documented file paths still exist?
>    - Do documented env variables match what code uses?
>    - Are deployment instructions still accurate?
> 3. Check .claude/ alignment:
>    - Do agent descriptions match codebase structure?
>    - Do skill instructions reference existing files/patterns?
>    - Do rules reference existing paths?
> 4. Write report to monitoring/docs-drift-latest.md:
>    summary, drift items with file references, missing docs, stale refs
> 5. If report changed, commit and push:
>    chore(monitoring): update docs drift report
>    Only commit files under monitoring/

---

### weekly-retro

**Frequency:** Weekly (Friday)
**Model:** Sonnet
**What it does:** Generates a weekly summary of project activity.
**Output:** `monitoring/weekly-retro-latest.md`

Prompt:

> You are a project retrospective summarizer.
>
> 1. Check git log for the past 7 days: commits, PRs, branches
> 2. Read the latest sprint files in tasks/sprints/ (if any new ones)
> 3. Read monitoring/ reports from this week
> 4. Read tasks/backlog.md for changes
> 5. Write a weekly summary to monitoring/weekly-retro-latest.md:
>    - What was done (commits, features, fixes)
>    - What was found (monitoring alerts, audit results)
>    - What's next (top backlog items, upcoming work)
>    - Metrics: commits this week, files changed, tests status
> 6. If report changed, commit and push:
>    chore(monitoring): update weekly retrospective
>    Only commit files under monitoring/

---

### test-health

**Frequency:** Daily
**Model:** Sonnet
**What it does:** Runs the test suite and reports status.
**Output:** `monitoring/test-health-latest.md`

Prompt:

> You are a test health monitor for this project.
>
> 1. Detect the test runner (vitest, pytest, jest, cargo test, etc.)
> 2. Run the full test suite
> 3. If tests fail: identify which tests, grep for recent changes
>    to those files, determine if the failure is new
> 4. Write report to monitoring/test-health-latest.md:
>    - Status: all passing / N failures
>    - Failed tests with file and error summary
>    - Recent commits that may have caused the failure
>    - Coverage summary if available
> 5. If any test fails, also save to monitoring/alerts/test-failure-[date].md
> 6. If report changed, commit and push:
>    chore(monitoring): update test health report
>    Only commit files under monitoring/

---

## Desktop agents — needs local access

These run on your machine. Access to local credentials, CLI tools,
and services. Only run when Mac is awake and Desktop is open.

### health-check (infra)

**Frequency:** Every 3 hours
**Model:** Sonnet
**What it does:** Checks cloud infrastructure health via local CLI.
**Output:** `monitoring/health-check-latest.md`

Note: This task needs local credentials that are not available in cloud
agents. Two provider variants below — use the one matching your stack,
or combine both if multi-cloud.

Prompt (AWS variant):

> You are an infrastructure health monitor.
>
> 1. Use AWS CLI to check:
>    - ECS/Lambda service status and recent errors
>    - DynamoDB throttles and capacity
>    - API Gateway 5xx error rate
>    - CloudWatch alarms in ALARM state
>    - Recent deploy events
> 2. Write report to monitoring/health-check-latest.md:
>    - Status per service: healthy / degraded / critical
>    - Error rates and trends
>    - Active alarms
>    - Scan timestamp
> 3. If any service is critical, save to monitoring/alerts/infra-[date].md
> 4. Commit if changed: chore(monitoring): update health check report

Prompt (GCP variant):

> You are an infrastructure health monitor.
>
> 1. Use gcloud CLI to check:
>    - Cloud Run service status and recent error logs
>    - Cloud SQL instance health and connection count
>    - Load balancer 5xx error rate (via gcloud logging)
>    - Active Cloud Monitoring alerts
>    - Recent deploy events (Cloud Deploy / Cloud Build)
> 2. Write report to monitoring/health-check-latest.md:
>    - Status per service: healthy / degraded / critical
>    - Error rates and trends
>    - Active alerts
>    - Scan timestamp
> 3. If any service is critical, save to monitoring/alerts/infra-[date].md
> 4. Commit if changed: chore(monitoring): update health check report

---

## Desktop agents with external connectors

These run as Desktop scheduled tasks with MCP connectors (Slack, Gmail,
Google Calendar, Drive, etc.) configured in Claude Desktop. Only run
when Mac is awake.

### daily-brief

**Frequency:** Daily (morning)
**Model:** Sonnet
**What it does:** Pulls from connected tools to produce a morning briefing.
**Output:** Claude Code session (not committed to repo)

Note: This task needs Slack, email, and/or calendar connectors that
are configured in Claude Desktop. It does NOT write to the repo — the
briefing is consumed directly in Claude Code or via Dispatch on phone.

Prompt:

> Produce a morning briefing for today:
>
> 1. Check Slack for unread messages and mentions since yesterday
> 2. Check email for important messages (flagged, from known contacts)
> 3. Check calendar for today's meetings and deadlines
> 4. Check GitHub for open PRs, issues assigned to me, CI status
> 5. Format as a briefing:
>    - Today's schedule
>    - Messages needing response
>    - Code/project items needing attention
>    - Top 3 priorities for today
>
> Keep it concise. I read this on my phone.

---

## Session agents (`/loop`) — ephemeral

These run in your current Claude Code session. They die when the
session closes. Use for temporary monitoring.

### deploy-watch

**Frequency:** Every 5 minutes (during deploy)
**Model:** Current session model

```
/loop 5m check if the deploy finished. Look at CI status or
the deploy logs. If it's done, summarize the result. If it failed,
show me the error.
```

### pr-babysit

**Frequency:** Every 10 minutes

```
/loop 10m check PR #[number] for new comments or CI results.
If there are new review comments, summarize them. If CI failed,
show the error.
```

### log-watch

**Frequency:** Every 2 minutes (during active debugging)

```
/loop 2m tail the last 50 lines of [log file or service logs].
If you see new errors or exceptions, summarize them with the
timestamp and surrounding context. Stop reporting if it's quiet.
```
