---
name: data-analysis
description: >
  Fetch, query, and analyze project data. Use this skill when the user wants
  to investigate metrics, understand user behavior, debug a data issue, or
  answer a question that requires looking at real data. Triggers on "what
  happened", "why did X drop", "show me the numbers", "query", "metrics",
  "funnel", "cohort", "data", "analytics", "dashboard", "events", "logs".
  Even if the user just asks "what happened on Tuesday", use this skill —
  it has the query patterns and data sources to find out.
---

# Data Analysis

You answer data questions by fetching real data, not guessing. This skill
gives you the tools and query patterns to investigate.

Read `config.json` in this skill directory for data source configuration.
If it doesn't exist, ask the user to set it up (see Setup section).

## Data sources

Check `scripts/` for helper functions specific to this project. These scripts
encode domain knowledge (which tables to join, which event names to use,
how to dedupe) so you don't have to figure it out each time.

If helper scripts exist, **compose** them — import and combine rather than
rewriting from scratch. Generate new investigation scripts on the fly that
use the helpers. Save useful investigation scripts in `scripts/` for reuse.

If no helpers exist yet, write the query directly, then extract reusable
parts into helpers for next time.

## Common investigation patterns

Adapt these to the project's actual data stack:

**"What happened on [date]?"** — Compare the target day against the previous
day and same day last week. Look at volume, error rate, and key conversion
points.

**"Why did [metric] drop?"** — Segment by the obvious dimensions first
(source, device, geography, plan tier). The segment where the drop is
concentrated tells you where to dig.

**"Is [thing] working?"** — Define "working" as a measurable assertion.
Query the data, check the assertion, report the result.

**"Compare A vs B"** — Pull the same metrics for both cohorts. Flag
differences that exceed normal variance. Note sample sizes.

## How to query

Use whatever the project provides — adapt to the stack:
- **SQL databases**: Write queries directly or use helper scripts
- **AWS CloudWatch**: Use `aws cloudwatch get-metric-statistics`
- **DynamoDB**: Use `aws dynamodb query` with appropriate key conditions
- **Event systems**: Use the project's event query library
- **Logs**: Use `aws logs filter-log-events` or grep on log files
- **Third-party APIs**: Stripe dashboard data, Discord analytics, etc.

Always show your work: the query you ran, the raw numbers, then your
interpretation. Don't just state conclusions.

## Output

```markdown
# Data Analysis — [question or topic]

## Question
[What we're trying to answer]

## Method
[Data source, query approach, time range]

## Findings
[Key numbers, with context and comparison]

## Interpretation
[What the data means — not what it says, but what it implies]

## Next steps
[Further investigation if needed, or action items]
```

## Setup

Create `config.json` in this skill directory:

```json
{
  "data_stack": "postgres|dynamodb|cloudwatch|custom",
  "primary_db": {
    "type": "dynamodb",
    "region": "us-east-1",
    "tables": ["users", "events", "billing"]
  },
  "key_metrics": [
    "daily_active_users",
    "signup_to_activation_rate",
    "revenue"
  ],
  "event_names": {
    "signup": "signup_completed",
    "activation": "first_action_completed",
    "upgrade": "checkout_completed"
  }
}
```

## Gotchas
- Use event names from config, not guesses. "signup_completed" and "signup_started" are very different numbers.
- Always dedupe before counting. The same event can fire multiple times.
- Show raw numbers AND percentages. "50% drop" on 4 events is noise, on 4000 it's a crisis.
- Time zones matter. Specify UTC or local in every query.
- Don't just state what changed — explain what it means for the business.

## Memory
Append each investigation to `${CLAUDE_PLUGIN_DATA}/investigations.log`
if available, otherwise to `tasks/data-investigations.log`:
```
[YYYY-MM-DD] Q: [question] → A: [one-line finding]
```
This log helps spot recurring questions and build better dashboards.