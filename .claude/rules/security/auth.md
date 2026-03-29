---
paths:
  - "src/auth/**"
  - "src/crypto/**"
  - "src/security/**"
  - "src/middleware/auth*"
  - "**/*auth*"
  - "**/*token*"
  - "**/*session*"
---

# Security Conventions

## Authentication
- Use bcrypt (cost factor >= 12) or argon2id for password hashing. Never use MD5 or SHA for passwords.
- JWT tokens expire after 15 minutes maximum. Use refresh tokens for longer sessions.
- Invalidate all sessions on password change.
- Implement account lockout after 5 failed login attempts.

## Authorization
- Check permissions on every request. Never rely on UI to hide unauthorized actions.
- Use allow-lists, not deny-lists. Deny by default, allow explicitly.
- Audit log every authorization decision on sensitive operations (admin actions, data access, payment).

## Secrets management
- Never hardcode secrets in source code. Use environment variables or a secrets manager.
- Never log secrets, tokens, passwords, or API keys — even partially.
- Rotate secrets on a schedule and immediately on suspected compromise.

## Data protection
- Encrypt sensitive data at rest (PII, financial data, health data).
- Use TLS for all data in transit. No exceptions.
- Minimize data collection. Do not store data you do not need.
- Implement data retention policies. Delete data when no longer needed.

## Session management
- Generate session IDs with cryptographically secure random generators.
- Set secure cookie flags: `HttpOnly`, `Secure`, `SameSite=Strict`.
- Implement idle timeout and absolute timeout for sessions.

## Input handling
- Validate all inputs server-side, even if validated client-side.
- Use parameterized queries for all database operations. Never concatenate user input into queries.
- Encode output to prevent XSS. Use the framework's built-in escaping.

## Dependency security
- Run vulnerability scans on dependencies regularly (`npm audit`, `pip audit`).
- Do not use dependencies with known critical vulnerabilities without a mitigation plan.
- Pin dependency versions in production. Review changelogs before upgrading.