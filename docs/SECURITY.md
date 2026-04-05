# Security Posture — Claude Code Headless Mode

> **Version**: v3.4
> **Applies to**: Autonomous sprint execution with `--dangerously-skip-permissions`
> **Claim**: This mode is safer than an open terminal for the operations it performs.

---

## What `--dangerously-skip-permissions` actually means

The flag bypasses **Claude Code's interactive approval prompts** — the dialogs
that ask "Allow this bash command? [y/n]". It does NOT:

- Bypass the `deny` list in `settings.json` — those patterns are always blocked
- Bypass command-type hooks (linter, test runner, secret scanner) — those always run
- Give Claude access to anything it couldn't already access with your user account
- Remove the LLM judge PreToolUse evaluation

It's called "dangerous" because it removes the human from each individual command
approval. The guards below replace that human with deterministic and LLM-based
controls.

---

## The 6 layers of defense in depth

### Layer 1 — Deny-list (settings.json `permissions.deny`)

Hard-blocked patterns. Applied by the Claude Code runtime before any hook or LLM
evaluation. Cannot be bypassed by any flag or prompt injection.

| Category | Blocked patterns |
|----------|-----------------|
| File destruction | `rm -rf /`, `rm -rf ~`, `rm -rf .`, `rm -rf *` |
| Database | `DROP TABLE`, `DROP DATABASE`, `DELETE FROM`, `TRUNCATE` |
| Git destructive | `git push --force`, `git push -f`, `git push origin main/master`, `git reset --hard` |
| Permissions | `chmod 777`, `chmod -R 777` |
| Remote execution | `curl * \| sh`, `curl * \| bash`, `wget * \| sh` |
| Disk/system | `> /dev/sda`, `mkfs`, `dd if=`, `shutdown`, `reboot` |
| Publishing | `npm publish`, `pip upload` |
| Infrastructure | `terraform destroy`, `kubectl delete` |
| Git untracked | `git clean -f`, `git clean -fd` |
| Cloud storage | `aws s3 rm` |
| System scheduling | `crontab -r` |

**Why this is stronger than a terminal:** An open terminal has none of these guards.
A tired developer or a copy-pasted script can run any of these. The deny-list is
always on, even at 3am during an automated sprint. (31 patterns total)

### Layer 2 — LLM judge PreToolUse hooks

Two prompt-type hooks evaluate intent before any write or bash command.

**Write/Edit hook** — blocks writes outside the project directory:
- System files: `/etc/`, `/usr/`, `/System/`
- User dotfiles: `~/.bashrc`, `~/.zshrc`, `~/.ssh/`
- Any absolute path not inside the current project

**Bash hook** — evaluates each command for intent. Explicit block list:

- Deleting files outside the project directory
- Force pushing to any branch
- Piping remote scripts to shell
- Database destructive operations
- Publishing packages to registries
- Disk/partition operations
- Exposing secrets in commands
- Modifying `.env` or credentials files

Explicit safe list (always approved without latency):

- `claude -p` sub-sessions (sprint orchestration)
- Git operations on feature branches
- Package installation (`npm install`, `pip install`, `brew install`)
- Test runners, linters, formatters
- Read operations (`grep`, `find`, `ls`, `cat`)
- Docker build / compose
- AWS CLI read operations

**Why this matters:** Catches intent-based threats the deny-list can't pattern-match
(e.g., a creative way to delete files that doesn't use `rm -rf`, or a write
to `~/.bashrc` that would persist malicious behavior beyond the session).

### Layer 3 — Deterministic command hooks

Three command-type hooks that always run, regardless of permissions mode:

| Hook | Event | What it enforces |
|------|-------|-----------------|
| **Stop** | Phase ends | Tests must pass — Claude cannot declare "done" with failing tests |
| **Linter** (PostToolUse) | After Write/Edit | Auto-lints JS/TS/Python after every file modification |
| **Secret scanner** (PostToolUse) | After Write/Edit | Blocks commit if hardcoded secrets detected in source files |

Secret scanner patterns (applied to `.js`, `.ts`, `.py`, `.json`, `.yaml`, etc.):
- AWS access key IDs (`AKIA[0-9A-Z]{16}`)
- Stripe live secret keys (`sk_live_...`)
- GitHub personal access tokens (`ghp_...`)
- PEM private keys (`-----BEGIN PRIVATE`, `-----BEGIN RSA`)
- Generic hardcoded assignments (`SECRET=<literal>`, `API_KEY=<literal>`)

**Why this matters:** These run even if Claude "decides" the file is fine.
A hook doesn't reason — it executes. The secret scanner will catch an accidentally
hardcoded key before it reaches a commit.

### Layer 4 — Scoped security rules (`.claude/rules/security/`)

Two rule files loaded automatically when Claude touches security-sensitive code:

- `security/auth.md` — loaded for `src/auth/**`, `**/*token*`, `**/*session*`
- `security/secrets.md` — loaded for `.env*`, `config/**`, `**/*.pem`, `**/*.key`

These rules are injected into Claude's context when it modifies matching files,
ensuring security conventions are applied at the point of writing — not discovered
later in review.

**Why this matters:** Claude doesn't need to be reminded "don't hardcode secrets"
globally. The rule activates exactly when it's relevant.

### Layer 5 — Workflow review step (`/capture-lessons` Step 4)

At the end of every sprint, the `/capture-lessons` skill includes a mandatory
"Review workflow configuration" step that evaluates:

- Bug classes found 2+ times → propose a new hook to prevent them
- Reviewer flags a manual check → automate it as a hook
- New code area with specific patterns → create a scoped rule
- Manual step done 2+ times → create a skill

This means the security posture **self-improves with every sprint**. Each sprint
that finds a new class of issue automatically prompts adding a deterministic guard
for the next sprint.

### Layer 6 — Audit trail (briefs/ + decisions-log.md)

Every strategic decision is logged in `briefs/decisions-log.md`. Sprint outputs
are preserved in `tasks/sprints/sprint-XX/`. This means:

- Full reproducibility: every change has a traceable decision chain
- SP-QA independently reviews every sprint before the next one starts
- Blockers requiring human intervention are surfaced in `briefs/blockers.md`
- Nothing is silently discarded

---

## Comparison: headless Claude vs alternatives

| Guard | Open terminal | CI/CD pipeline | Claude headless (v3.4) |
|-------|--------------|----------------|----------------------|
| Deny-list (destructive cmds) | ❌ | Partial | ✅ 31 patterns |
| LLM intent evaluation | ❌ | ❌ | ✅ |
| Tests must pass before "done" | ❌ | ✅ | ✅ |
| Secret scan on every write | ❌ | Optional | ✅ |
| Auto-lint on every write | ❌ | Optional | ✅ |
| Security rules at write time | ❌ | ❌ | ✅ |
| Audit trail of every decision | ❌ | Partial | ✅ |
| Self-improving security posture | ❌ | ❌ | ✅ |

---

## Per-stack guidance

### Node.js / TypeScript
- Secrets via `process.env.KEY` — the secret scanner blocks literal assignments
- `npm publish` is deny-listed — accidental registry pushes are impossible
- ESLint runs automatically after every file write

### Python
- Secrets via `os.environ['KEY']` or `python-dotenv` loading `.env`
- `pip upload` is deny-listed
- Ruff/flake8 runs automatically after every `.py` write

### AWS
- Use IAM roles — never put `AKIA...` keys in code (secret scanner blocks it)
- AWS CLI read operations are explicitly safe-listed in the LLM judge
- Destructive AWS operations (`aws ec2 terminate`, etc.) caught by LLM judge

### Stripe
- `sk_live_` keys blocked by secret scanner
- Use `sk_test_` in development, environment variables in production
- Stripe webhooks: `whsec_` secrets also covered by the scanner

### Docker
- `docker build` and `docker compose` are explicitly safe-listed
- Base image pinning enforced by `rules/infra/cicd.md`
- Non-root container user enforced by the same rule

### Frontend only
- No backend secrets to protect — scanner still catches API keys in JS bundles
- `npm publish` deny-listed — no accidental CDN pushes

---

## What this doesn't protect against

Be honest about the limits:

1. **Secrets already in the environment** — if `$STRIPE_SECRET_KEY` is set,
   Claude can read and use it. This is intentional (it needs to run the app).
   Scope your environment to only what the sprint needs.

2. **Novel destruction patterns** — the deny-list covers known patterns. A
   sufficiently creative command might bypass it. The LLM judge is the backstop,
   but it can be wrong.

3. **Exfiltration via legitimate channels** — Claude could theoretically send
   data via `curl` to a legitimate endpoint. Trust the model, audit `briefs/`
   and `decisions-log.md` if something looks off.

4. **Supply chain via dependencies** — `npm install` is safe-listed. A malicious
   package could execute code at install time. Use `npm audit` (automated via
   scheduled tasks).

---

## Verifying the setup

```bash
# Run the verification script
bash verify-v33.sh

# Manually test the deny-list (should be blocked)
# Do NOT run these — they're for documentation only:
# git push origin main       → blocked by deny-list
# rm -rf .                   → blocked by deny-list
# terraform destroy          → blocked by deny-list

# Test the secret scanner (create a temp file with a fake key):
# echo 'API_KEY=abcdefghijklmnopqrstuvwxyz123456' > /tmp/test_secret.js
# The PostToolUse hook would block writing this file from Claude
```
