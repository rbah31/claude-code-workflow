#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Sprint Workflow Template — Full Verification
# Run from the template root directory
# ═══════════════════════════════════════════════════════════

echo "═══ SPRINT WORKFLOW TEMPLATE — VERIFICATION ═══"
echo ""

PASS=0; FAIL=0; WARN=0
check() {
  if eval "$2" 2>/dev/null; then echo "  ✅ $1"; ((PASS++))
  else echo "  ❌ $1"; ((FAIL++)); fi
}
warn() {
  if eval "$2" 2>/dev/null; then echo "  ✅ $1"; ((PASS++))
  else echo "  ⚠️  $1 (optional)"; ((WARN++)); fi
}

# ─── 1. CORE STRUCTURE ───
echo "══ 1. Core structure ══"
check "CLAUDE.md" "[ -f .claude/CLAUDE.md ]"
check "settings.json" "[ -f .claude/settings.json ]"
check "tasks/backlog.md" "[ -f tasks/backlog.md ]"
check "tasks/lessons.md" "[ -f tasks/lessons.md ]"
check "tasks/sprints/" "[ -d tasks/sprints ]"
check "monitoring/" "[ -d monitoring ]"
check ".gitignore" "[ -f .gitignore ]"

# ─── 2. AGENTS ───
echo ""
echo "══ 2. Agents (5 universal + ops-monitor) ══"
check "architect.md" "[ -f .claude/agents/architect.md ]"
check "code-reviewer.md" "[ -f .claude/agents/code-reviewer.md ]"
check "security-auditor.md" "[ -f .claude/agents/security-auditor.md ]"
check "ops-engineer.md" "[ -f .claude/agents/ops-engineer.md ]"
check "qa-tester.md" "[ -f .claude/agents/qa-tester.md ]"
check "ops-monitor.md" "[ -f .claude/agents/ops-monitor.md ]"

# ─── 3. SKILLS ───
echo ""
echo "══ 3. Skills (6 cycle + utilities) ══"
check "sprint-plan" "[ -f .claude/skills/sprint-plan/SKILL.md ]"
check "build" "[ -f .claude/skills/build/SKILL.md ]"
check "review" "[ -f .claude/skills/review/SKILL.md ]"
check "fix" "[ -f .claude/skills/fix/SKILL.md ]"
check "red-team" "[ -f .claude/skills/red-team/SKILL.md ]"
check "capture-lessons" "[ -f .claude/skills/capture-lessons/SKILL.md ]"
check "remote-fix" "[ -f .claude/skills/remote-fix/SKILL.md ]"
check "monitoring-briefing" "[ -f .claude/skills/monitoring-briefing/SKILL.md ]"

# ─── 4. RULES ───
echo ""
echo "══ 4. Rules ══"
check "general.md" "[ -f .claude/rules/general.md ]"
check "Cache discipline in general" "grep -qi 'cache' .claude/rules/general.md"
check "Session discipline in general" "grep -qi 'session' .claude/rules/general.md"

# ─── 5. HOOKS ───
echo ""
echo "══ 5. Hooks in settings.json ══"
check "Stop hook" "grep -q 'Stop' .claude/settings.json"
check "PostToolUse hook" "grep -q 'PostToolUse' .claude/settings.json"
check "PreToolUse hook" "grep -q 'PreToolUse' .claude/settings.json"
check "SubagentStop hook" "grep -q 'SubagentStop' .claude/settings.json"
check "Notification hook" "grep -q 'Notification' .claude/settings.json"
check "Agent Teams enabled" "grep -q 'AGENT_TEAMS' .claude/settings.json"

# ─── 6. CHANNEL MODE ───
echo ""
echo "══ 6. Channel mode in skills ══"
check "Channel mode in build" "grep -qi 'channel\|remote\|dispatch\|telegram' .claude/skills/build/SKILL.md"
check "Channel mode in review" "grep -qi 'channel\|remote\|dispatch\|telegram' .claude/skills/review/SKILL.md"
check "Channel mode in sprint-plan" "grep -qi 'channel\|remote\|dispatch\|telegram' .claude/skills/sprint-plan/SKILL.md"

# ─── 7. DOCUMENTATION ───
echo ""
echo "══ 7. Documentation ══"
check "WORKFLOW.md" "[ -f docs/WORKFLOW.md ]"
check "scheduled-tasks-prompts.md" "[ -f docs/scheduled-tasks-prompts.md ]"
check "mac-persistent-setup.md" "[ -f docs/mac-persistent-setup.md ]"
check "mac-persistent-setup.sh" "[ -f docs/mac-persistent-setup.sh ]"
check "REFERENCES.md" "[ -f docs/REFERENCES.md ]"

# ─── 8. REFERENCES CONTENT ───
echo ""
echo "══ 8. References content ══"
check "Thariq references" "grep -qi 'thariq\|shihipar' docs/REFERENCES.md"
check "Anthropic engineering blog" "grep -qi 'anthropic.*engineering\|harness.*design\|building.*agents' docs/REFERENCES.md"
check "Boris Cherny tips" "grep -qi 'bare\|add-dir\|boris\|cherny' docs/REFERENCES.md"
check "Claude Code docs links" "grep -qi 'code.claude.com' docs/REFERENCES.md"

# ─── 9. WORKFLOW CONTENT ───
echo ""
echo "══ 9. Workflow content ══"
check "--bare documented" "grep -q 'bare' docs/WORKFLOW.md"
check "--add-dir documented" "grep -q 'add-dir' docs/WORKFLOW.md"
check "--agent documented" "grep -q 'agent' docs/WORKFLOW.md"
check "/voice documented" "grep -qi 'voice' docs/WORKFLOW.md"
check "Remote ops section" "grep -qi 'remote' docs/WORKFLOW.md"
check "Mac persistent section" "grep -qi 'persistent\|amphetamine\|mac' docs/WORKFLOW.md"
check "Scheduled tasks section" "grep -qi 'schedule' docs/WORKFLOW.md"

# ─── 10. V4 DESIGN ───
echo ""
echo "══ 10. V4 design document ══"
check "WORKFLOW-V4-DESIGN.md exists" "[ -f docs/WORKFLOW-V4-DESIGN.md ]"
check "Strategic layer section" "grep -qi 'strategic.*layer\|SP-PM\|SP-QA' docs/WORKFLOW-V4-DESIGN.md"
check "Debate protocol" "grep -qi 'sycophancy\|debate\|troublemaker' docs/WORKFLOW-V4-DESIGN.md"
check "Token economics" "grep -qi 'token\|cost\|max.*plan\|API' docs/WORKFLOW-V4-DESIGN.md"
check "Implementation plan" "grep -qi 'phase.*1\|phase.*2\|implementation' docs/WORKFLOW-V4-DESIGN.md"
check "briefs/ structure" "grep -qi 'briefs\|project-state\|sprint-directive' docs/WORKFLOW-V4-DESIGN.md"

# ─── 11. OPEN SOURCE FILES ───
echo ""
echo "══ 11. Open source files ══"
check "README.md" "[ -f README.md ]"
check "LICENSE" "[ -f LICENSE ]"
check "CONTRIBUTING.md" "[ -f CONTRIBUTING.md ]"

# ─── 12. GENERICITY ───
echo ""
echo "══ 12. Genericity (no personal data) ══"
PERSONAL=$(grep -ri "sampleapp\|samplebot\|example\|example\|rayanbah" --include="*.md" --include="*.json" --include="*.sh" --include="*.yaml" . 2>/dev/null | grep -v "node_modules" | grep -v ".git/" | grep -v "settings.local.json" | wc -l)
check "No personal references ($PERSONAL found)" "[ $PERSONAL -eq 0 ]"

# ─── 13. LANGUAGE ───
echo ""
echo "══ 13. Language (all English) ══"
FRENCH=$(grep -ri "français\|en français\|guillemets\|voici\|voilà\|puisque\|d'abord\|étape\|réflexe\|dernière" --include="*.md" --include="*.sh" . 2>/dev/null | grep -v "node_modules" | grep -v ".git/" | grep -v "WORKFLOW-V4" | wc -l)
check "No French content ($FRENCH found)" "[ $FRENCH -eq 0 ]"

# ─── 14. TEMPLATES CLEAN ───
echo ""
echo "══ 14. Clean templates ══"
BACKLOG_CONTENT=$(wc -l < tasks/backlog.md 2>/dev/null || echo 999)
LESSONS_CONTENT=$(wc -l < tasks/lessons.md 2>/dev/null || echo 999)
check "backlog.md is template (< 30 lines)" "[ $BACKLOG_CONTENT -lt 30 ]"
check "lessons.md is template (< 30 lines)" "[ $LESSONS_CONTENT -lt 30 ]"
check "monitoring/ is empty (only .gitkeep)" "[ $(ls monitoring/ 2>/dev/null | grep -v .gitkeep | wc -l) -eq 0 ]"

# ─── 15. VERIFY SCRIPT ───
echo ""
echo "══ 15. Existing verify script ══"
warn "verify.sh exists" "[ -f verify.sh ]"

# ─── RESULTS ───
echo ""
echo "══════════════════════════════════════════"
echo "  RESULTS"
echo "══════════════════════════════════════════"
TOTAL=$((PASS + FAIL))
echo "  Passed: $PASS/$TOTAL"
[ "$WARN" -gt 0 ] && echo "  Warnings: $WARN (optional items)"
[ "$FAIL" -eq 0 ] && echo "  🟢 ALL CHECKS PASSED" || echo "  🔴 $FAIL CHECKS FAILED"
echo "══════════════════════════════════════════"