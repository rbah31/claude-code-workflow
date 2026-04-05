---
paths:
  - ".env*"
  - "config/**"
  - "**/*credentials*"
  - "**/*secret*"
  - "**/*.pem"
  - "**/*.key"
  - "**/*.p12"
  - "**/*.pfx"
  - "**/secrets/**"
---

# Secrets Handling Conventions

## Absolute rules
- Never hardcode a secret, token, API key, or password in source code.
- Never commit `.env` files that contain real values. Use `.env.example`
  with placeholder values only.
- Never log secrets, even partially. No `console.log(apiKey)` or
  `print(token[:4] + "...")`.
- Never pass secrets as CLI arguments — they appear in shell history and
  process lists.

## How to reference secrets correctly

**Node.js / TypeScript:**
```js
const apiKey = process.env.STRIPE_SECRET_KEY;
if (!apiKey) throw new Error('STRIPE_SECRET_KEY is not set');
```

**Python:**
```python
import os
api_key = os.environ['STRIPE_SECRET_KEY']  # raises KeyError if missing — good
```

**Docker Compose:**
```yaml
environment:
  - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}  # from host env, never inline
```

**GitHub Actions:**
```yaml
env:
  STRIPE_SECRET_KEY: ${{ secrets.STRIPE_SECRET_KEY }}
```

**AWS SDK (use IAM roles, not hardcoded keys):**
```js
// Good — SDK picks up credentials from instance role / env automatically
const client = new S3Client({ region: 'us-east-1' });

// Bad — never do this
const client = new S3Client({ credentials: { accessKeyId: 'AKIA...', secretAccessKey: '...' } });
```

## .env file discipline
- `.env` → real values, always gitignored, never committed
- `.env.example` → placeholder values, committed, kept in sync with `.env`
- `.env.test` → test-only values (no live keys), may be committed if
  values are non-sensitive test credentials

## If a secret is accidentally committed

1. Rotate the secret immediately — treat it as compromised regardless of
   how quickly you removed it. Git history is public and cached.
2. Remove from git history: `git filter-repo --path <file> --invert-paths`
   or BFG Repo Cleaner.
3. Force-push cleaned history (requires human action — blocked in headless mode).
4. Notify affected service (Stripe, AWS, etc.) of potential exposure.
5. Add the file to `.gitignore` and a pre-commit hook to prevent recurrence.

## AWS-specific
- Use IAM roles for EC2/Lambda — never put AWS keys in code or `.env` in prod.
- Rotate IAM access keys every 90 days for non-role-based access.
- Use AWS Secrets Manager or Parameter Store for application secrets in prod.
- `AKIA...` in source code is an instant block — the secret scan hook will catch it.

## Stripe-specific
- `sk_live_` keys are production. Never use them in development or tests.
- Use `sk_test_` for development. Webhook signatures use `whsec_`.
- Restrict live keys to IP allowlists in the Stripe dashboard.

## Patterns the secret scan hook detects
The PostToolUse hook scans every written file for:
- AWS access key IDs (`AKIA[0-9A-Z]{16}`)
- Stripe live secret keys (`sk_live_...`)
- GitHub personal access tokens (`ghp_...`)
- PEM private keys (`BEGIN PRIVATE KEY`)
- Generic hardcoded secrets (`API_KEY=<literal value>`)

If triggered: fix the file to use an environment variable, then re-save.
