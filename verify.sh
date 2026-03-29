#!/bin/bash
# Template Workflow v3.2 — Full Verification Script
# Run from the root of the template repo

echo "========================================"
echo "  TEMPLATE WORKFLOW v3.2 — VERIFICATION"
echo "========================================"

PASS=0
FAIL=0

check() {
  if eval "$2" 2>/dev/null; then
    echo "  ✅ $1"
    ((PASS++))
  else
    echo "  ❌ $1"
    ((FAIL++))
  fi
}

# ── STRUCTURE ──────────────────────────────────────────────
echo ""
echo "═══ FILE STRUCTURE ═══"

echo ""
echo "--- Core ---"
check "CLAUDE.md" "[ -f .claude/CLAUDE.md ]"
check "settings.json" "[ -f .claude/settings.json ]"
check "README.md" "[ -f README.md ]"
check "docs/WORKFLOW.md" "[ -f docs/WORKFLOW.md ]"
check "docs/scheduled-tasks-prompts.md" "[ -f docs/scheduled-tasks-prompts.md ]"
check ".gitignore" "[ -f .gitignore ]"
check "tasks/backlog.md" "[ -f tasks/backlog.md ]"
check "tasks/lessons.md" "[ -f tasks/lessons.md ]"
check "tasks/sprints/sprint-XX/" "[ -d tasks/sprints/sprint-XX ]"
check "monitoring/" "[ -d monitoring ]"

echo ""
echo "--- Agents (5 universal) ---"
for agent in architect code-reviewer security-auditor ops-engineer qa-tester; do
  check "agents/$agent.md" "[ -f .claude/agents/$agent.md ]"
done

echo ""
echo "--- Rules (5 files) ---"
check "rules/general.md" "[ -f .claude/rules/general.md ]"
check "rules/backend/api.md" "[ -f .claude/rules/backend/api.md ]"
check "rules/frontend/components.md" "[ -f .claude/rules/frontend/components.md ]"
check "rules/security/auth.md" "[ -f .claude/rules/security/auth.md ]"
check "rules/infra/cicd.md" "[ -f .claude/rules/infra/cicd.md ]"

echo ""
echo "--- Cycle skills (6) ---"
for skill in sprint-plan build review fix red-team capture-lessons; do
  check "skills/$skill/SKILL.md" "[ -f .claude/skills/$skill/SKILL.md ]"
done

echo ""
echo "--- Utility skills (5) ---"
for skill in product-verification data-analysis scaffolding runbook remote-fix; do
  check "skills/$skill/SKILL.md" "[ -f .claude/skills/$skill/SKILL.md ]"
done

echo ""
echo "--- Red-team progressive disclosure ---"
check "red-team/references/attack-categories.md" "[ -f .claude/skills/red-team/references/attack-categories.md ]"
check "red-team/references/script-template.py" "[ -f .claude/skills/red-team/references/script-template.py ]"
check "red-team/evals/evals.json" "[ -f .claude/skills/red-team/evals/evals.json ]"

echo ""
echo "--- Data-analysis progressive disclosure ---"
check "data-analysis/scripts/helpers.py" "[ -f .claude/skills/data-analysis/scripts/helpers.py ]"

echo ""
echo "--- Scaffolding templates dir ---"
check "scaffolding/templates/" "[ -d .claude/skills/scaffolding/templates ]"

echo ""
echo "--- Runbook references dir ---"
check "runbook/references/" "[ -d .claude/skills/runbook/references ]"

# ── SKILLS QUALITY ─────────────────────────────────────────
echo ""
echo "═══ SKILL QUALITY ═══"

echo ""
echo "--- STOP in 6 cycle skills ---"
for skill in sprint-plan build review fix red-team capture-lessons; do
  check "$skill — STOP" "grep -q 'STOP' .claude/skills/$skill/SKILL.md"
done

echo ""
echo "--- Gotchas in 11 skills ---"
for skill in sprint-plan build review fix red-team capture-lessons product-verification data-analysis scaffolding runbook remote-fix; do
  check "$skill — Gotchas" "grep -q '## Gotchas' .claude/skills/$skill/SKILL.md"
done

echo ""
echo "--- Trigger-focused descriptions ---"
for skill in sprint-plan build review fix red-team capture-lessons product-verification data-analysis scaffolding runbook remote-fix; do
  check "$skill — triggers in description" "head -15 .claude/skills/$skill/SKILL.md | grep -qi 'use.*when\|trigger\|also use'"
done

echo ""
echo "--- Memory in skills that use it ---"
for skill in build capture-lessons product-verification data-analysis scaffolding runbook; do
  check "$skill — Memory section" "grep -q '## Memory' .claude/skills/$skill/SKILL.md"
done

echo ""
echo "--- Config/Setup pattern in utility skills ---"
for skill in product-verification data-analysis scaffolding runbook; do
  check "$skill — config.json pattern" "grep -q 'config.json' .claude/skills/$skill/SKILL.md"
done

# ── WORKFLOW FEATURES ──────────────────────────────────────
echo ""
echo "═══ WORKFLOW FEATURES ═══"

echo ""
echo "--- Skill /review — conditional reviewers ---"
check "Review invokes ops-engineer" "grep -q 'ops-engineer' .claude/skills/review/SKILL.md"
check "Review invokes billing-auditor" "grep -q 'billing-auditor' .claude/skills/review/SKILL.md"
check "Review invokes product-reviewer" "grep -q 'product-reviewer' .claude/skills/review/SKILL.md"
check "Review — Conditional reviewers section" "grep -q 'Conditional reviewers' .claude/skills/review/SKILL.md"

echo ""
echo "--- Skill /build — protections ---"
check "Build — compact not clear" "grep -q 'compact.*NOT clear\|NOT clear.*compact' .claude/skills/build/SKILL.md"
check "Build — incremental save" "grep -qi 'checkpoint\|incrementally\|after each.*task' .claude/skills/build/SKILL.md"
check "Build — design system read" "grep -q 'design-system\|MASTER.md' .claude/skills/build/SKILL.md"

echo ""
echo "--- Skill /fix — guard rails ---"
check "Fix — 3-strikes" "grep -qi 'three\|3rd time\|3 attempts\|3 failed' .claude/skills/fix/SKILL.md"
check "Fix — architectural review" "grep -qi 'architect' .claude/skills/fix/SKILL.md"

echo ""
echo "--- Skill /red-team — attack scripts ---"
check "Red-team — executable script" "grep -q 'red_team_attacks.py\|attack.*script' .claude/skills/red-team/SKILL.md"
check "Red-team — 10 categories" "grep -q 'attack-categories' .claude/skills/red-team/SKILL.md"

echo ""
echo "--- Skill /capture-lessons — doc update ---"
check "Capture-lessons — Update documentation step" "grep -q 'Update documentation' .claude/skills/capture-lessons/SKILL.md"
check "Capture-lessons — Documentation updated in retro" "grep -q 'Documentation updated' .claude/skills/capture-lessons/SKILL.md"

echo ""
echo "--- Rules ---"
check "Session discipline in general.md" "grep -q 'Session discipline\|session discipline' .claude/rules/general.md"
check "CI/CD conventions in infra/cicd.md" "grep -q 'Pipeline hygiene\|pipeline hygiene' .claude/rules/infra/cicd.md"

echo ""
echo "--- WORKFLOW.md ---"
check "Version 3.2" "grep -q '3.2' docs/WORKFLOW.md"
check "Status indicators" "grep -q '🟢' docs/WORKFLOW.md"
check "Scheduled tasks section" "grep -q 'Scheduled tasks' docs/WORKFLOW.md"

echo ""
echo "--- v3.2 additions ---"
check "agents/ops-monitor.md" "[ -f .claude/agents/ops-monitor.md ]"
check "skills/remote-fix/SKILL.md" "[ -f .claude/skills/remote-fix/SKILL.md ]"
check "Cache discipline in general.md" "grep -q 'Cache discipline' .claude/rules/general.md"
for skill in sprint-plan build review fix red-team capture-lessons; do
  check "$skill — Channel mode" "grep -q 'Channel mode' .claude/skills/$skill/SKILL.md"
done

echo ""
echo "--- .gitignore ---"
check "monitoring/ entries" "grep -q 'monitoring/' .gitignore"
check "monitoring not globally gitignored" "! grep -qx 'monitoring/' .gitignore"

# ── AGENTS ─────────────────────────────────────────────────
echo ""
echo "═══ AGENTS ═══"

echo ""
echo "--- Required frontmatter ---"
for agent in architect code-reviewer security-auditor ops-engineer qa-tester; do
  check "$agent — memory: project" "grep -q 'memory: project' .claude/agents/$agent.md"
  check "$agent — model field" "grep -q 'model:' .claude/agents/$agent.md"
done

# ── HOOKS ──────────────────────────────────────────────────
echo ""
echo "═══ HOOKS (settings.json) ═══"

check "Hook Stop exists" "grep -q 'Stop' .claude/settings.json"
check "Hook PostToolUse exists" "grep -q 'PostToolUse' .claude/settings.json"
check "Hook PreToolUse exists" "grep -q 'PreToolUse' .claude/settings.json"
check "Hook SubagentStop exists" "grep -q 'SubagentStop' .claude/settings.json"
check "Hook Notification exists" "grep -q 'Notification' .claude/settings.json"

# ── SUMMARY ────────────────────────────────────────────────
echo ""
echo "========================================"
TOTAL=$((PASS + FAIL))
echo "  RESULT: $PASS/$TOTAL checks passed"
if [ "$FAIL" -eq 0 ]; then
  echo "  🟢 TEMPLATE COMPLETE — ready to use"
else
  echo "  🔴 $FAIL checks failed — see above"
fi
echo "========================================"
