# Lessons Learned

> Project knowledge capital. Read by each skill at the start of every phase.
> Updated automatically by `/capture-lessons` and manually after each significant correction.

---

<!-- Entry format (used by /capture-lessons):

### [Date] — [Author or "Claude"] — Sprint XX
**Context**: [What was happening]
**What went wrong (or right)**: [What happened]
**Lesson**: [The takeaway — a rule to follow going forward]

-->

<!-- Examples:

### 2026-03-01 — Alex — Sprint 01
**Context**: Building the authentication module
**What went wrong**: JWT configured without expiration, passed review undetected
**Lesson**: Always check JWT token expiration. Added to security/auth.md rule: "JWT expires after 15 min max."

### 2026-03-01 — Claude — Sprint 01
**Context**: First build deployment
**What went wrong**: Docker build failed on ARM64 — incompatible base image
**Lesson**: Use multi-arch images (e.g. `node:20-slim`) and test the build on the target architecture before pushing.

-->
