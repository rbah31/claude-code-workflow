# Attack Categories Reference

Cover at least 7 of these 10 categories per red team session. Prioritize
categories that match the sprint's scope.

## 1. Injection (INJ)
Malicious input that alters application behavior.
- Prompt injection (direct, indirect, jailbreak, role hijack)
- Command injection (shell escape, subprocess exploitation)
- Delimiter/encoding escape (unicode, homoglyphs, zero-width chars)
- Template injection (f-string, Jinja, format string)

## 2. Authentication & Authorization (AUTH)
Bypassing identity or permission checks.
- Auth bypass (missing middleware, expired token reuse)
- Privilege escalation (Free → Pro features, user → admin)
- Cross-tenant access (guild A reads guild B data)
- Session fixation, token theft, JWT manipulation

## 3. Data Exfiltration (EXFIL)
Extracting data the attacker should not see.
- Secret leaking (API keys, tokens in responses or logs)
- PII exposure (user data in error messages, debug output)
- Internal state disclosure (stack traces, config values, DB schema)
- Side-channel leaks (timing differences, error codes, response size)

## 4. Abuse & Resource Exhaustion (ABUSE)
Degrading service for legitimate users.
- Rate limit bypass (rotating headers, distributed requests)
- Resource exhaustion (huge payloads, recursive queries, token bombing)
- Spam flooding (mass command invocation)
- Cost amplification (trigger expensive LLM calls at scale)

## 5. Business Logic (BIZ)
Exploiting application rules for unintended outcomes.
- Billing bypass (free access to paid features, coupon stacking)
- Feature gate circumvention (API direct call vs UI enforcement)
- Quota evasion (reset timing abuse, multi-account pooling)
- Workflow manipulation (skip required steps, replay completed actions)

## 6. Race Conditions & Concurrency (RACE)
Exploiting timing between operations.
- Double-submit (upgrade clicked twice, duplicate payment)
- TOCTOU (check permission then act after permission revoked)
- Webhook replay (resubmit same Stripe/Discord webhook)
- Parallel requests (simultaneous writes to same resource)

## 7. Configuration & Secrets (CONFIG)
Exploiting deployment or environment mistakes.
- Env vars exposed (debug mode on, verbose logging in prod)
- Default credentials (unchanged admin passwords)
- Permissive CORS/CSP headers
- Sensitive files accessible (/.env, /debug, /health with secrets)

## 8. Infrastructure (INFRA)
Attacking the deployment layer.
- Open ports, unnecessary services exposed
- Permissive IAM roles (Lambda with admin access)
- Public S3 buckets or DynamoDB tables without auth
- Unpatched dependencies with known CVEs

## 9. Social Engineering & Impersonation (SOCIAL)
Manipulating users through the application.
- Fake admin messages (bot impersonation via embeds)
- Phishing via application features (malicious links in user content)
- Display name/avatar spoofing to impersonate staff
- Trust exploitation (pretend to be support or admin)

## 10. Supply Chain & Dependencies (SUPPLY)
Attacking through third-party code or services.
- Outdated packages with known vulnerabilities
- Typosquatting (similar package names in requirements)
- Compromised MCP servers or plugins
- Malicious webhook endpoints (redirect callbacks)