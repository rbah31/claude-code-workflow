---
paths:
  - ".github/workflows/**"
  - "Dockerfile"
  - "docker-compose*"
  - "scripts/deploy*"
  - "infrastructure/**"
  - "samconfig*"
  - "Makefile"
---

# CI/CD Conventions

## Pipeline hygiene
- Do not copy-paste manual deploy scripts into CI steps. Pipelines and
  manual scripts have different requirements (idempotency, rollback,
  secrets handling, logging).
- Each pipeline step should be atomic and independently retriable.
- Use GitHub Actions caching for dependencies (node_modules, pip cache).
- Pin action versions to SHA, not tags (e.g., actions/checkout@<sha>).

## Deployment
- Include a health check step after deploy (curl endpoint, verify 200).
- Include a rollback mechanism (previous version tag, blue-green, canary).
- Never deploy to production without staging validation first.
- Secrets via GitHub Secrets or AWS Secrets Manager. Never in code or env
  files committed to git.

## Docker
- Use multi-stage builds to minimize image size.
- Pin base image versions (node:20.11-slim, not node:latest).
- Run as non-root user in production containers.
- Include .dockerignore to exclude node_modules, .git, tests.

## Observability
- Log deploy start, end, and duration.
- Tag deploys in monitoring (CloudWatch annotation, Datadog event).
- Alert on deploy failure (Slack notification, GitHub status check).