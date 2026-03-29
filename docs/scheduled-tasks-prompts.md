# Scheduled Tasks — Catalog

## Which type to use

| Need | Type | Command |
|------|------|---------|
| Runs without laptop, repo access only | Cloud | `/schedule` in Claude Code |
| Needs local credentials (AWS, GCP) | Desktop | Schedule tab in Claude Desktop |
| Needs external connectors (Slack, Gmail, Calendar) | Cowork | /schedule in Cowork |
| Watch something for the next hour | Session | `/loop` in Claude Code CLI |

Cloud jobs commit results to `monitoring/`. Desktop jobs write locally
and push. Both converge in the repo via git. Cowork tasks produce
results in the Cowork UI (not in the repo).

---

### Slot strategy (Max plan: 3 cloud agents)

The Max plan allows 3 concurrent cloud scheduled agents. Prioritize
cloud slots for the most critical repo-only tasks:

| Priority | Slot | Recommended task |
|----------|------|-----------------|
| 1 | Cloud | Security scan (dependency audit) — daily |
| 2 | Cloud | Daily brief (aggregates all monitoring) — daily |
| 3 | Cloud | Weekly project health (backlog + docs + retro) — weekly |

Tasks needing local credentials (AWS, GCP, Stripe CLI) go to Desktop
scheduled tasks. Tasks needing external connectors (Slack, Gmail) go
to Cowork.

If you have fewer than 3 critical repo-only tasks, use remaining cloud
slots for test-health or any other repo-only automation.

The weekly-project-health task is a fusion pattern: it combines backlog
hygiene, docs drift, and weekly retro into a single run to save a slot.
Use this pattern when slot-constrained.

---

## Cloud agents (`/schedule`) — repo access only

These run on Anthropic's infrastructure. Fresh git checkout each run.
No local credentials, no local services. Can commit and push.

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

Note: This task needs local credentials (AWS CLI, GCP CLI, etc.)
that are not available in cloud agents. Adapt the prompt to your
cloud provider.

Prompt (AWS example):

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

---

## Cowork agents — needs connectors

These run in Cowork with access to MCP connectors (Slack, Gmail,
Google Calendar, Drive, etc.). Only run when Mac is awake.

### daily-brief

**Frequency:** Daily (morning)
**Model:** Sonnet
**What it does:** Pulls from connected tools to produce a morning briefing.
**Output:** Cowork UI (not committed to repo)

Note: This task needs Slack, email, and/or calendar connectors that
are configured in Cowork. It does NOT write to the repo — the
briefing is consumed in the Cowork UI or via Dispatch on phone.

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

---

## What NOT to schedule

- Sprint phases (/build, /review, /fix) — these need human validation
- Red team audits — these need human judgment on scope
- Anything involving payments, refunds, or user data mutations
- Content publishing or social media posting
- Decisions that affect product direction
