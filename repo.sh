echo "=== FILE TREE ==="
find . -not -path './.git/*' -type f | sort

echo ""
echo "=== VERIFICATION OF 11 KEY ELEMENTS ==="

echo "1. Rule infra/cicd.md:"
[ -f .claude/rules/infra/cicd.md ] && echo "  ✅ Exists" || echo "  ❌ MISSING"

echo "2. Skill /review — conditional reviewers:"
grep -q "Conditional reviewers" .claude/skills/review/SKILL.md 2>/dev/null && echo "  ✅ Present" || echo "  ❌ MISSING"

echo "3. Skill /build — compact not clear:"
grep -q "compact.*NOT clear" .claude/skills/build/SKILL.md 2>/dev/null && echo "  ✅ Present" || echo "  ❌ MISSING"

echo "4. Skill /red-team — references:"
[ -d .claude/skills/red-team/references ] && echo "  ✅ references/ exists" || echo "  ❌ MISSING"

echo "5. Scheduled tasks in WORKFLOW.md:"
grep -q "Scheduled tasks" docs/WORKFLOW.md 2>/dev/null && echo "  ✅ Present" || echo "  ❌ MISSING"

echo "6. scheduled-tasks-prompts.md:"
[ -f docs/scheduled-tasks-prompts.md ] && echo "  ✅ Exists" || echo "  ❌ MISSING"

echo "7. monitoring/:"
[ -d monitoring ] && echo "  ✅ Exists" || echo "  ❌ MISSING"

echo "8. Skill /fix — 3-strikes guard:"
grep -q "3.*failed\|three.*attempt" .claude/skills/fix/SKILL.md 2>/dev/null && echo "  ✅ Present" || echo "  ❌ MISSING"

echo "9. .gitignore — monitoring entries:"
grep -q "monitoring/" .gitignore 2>/dev/null && echo "  ✅ Present" || echo "  ❌ MISSING"

echo "10. README.md:"
[ -f README.md ] && echo "  ✅ Exists" || echo "  ❌ MISSING"

echo "11. WORKFLOW.md — version 3.2 + green status:"
grep -q "3.2" docs/WORKFLOW.md 2>/dev/null && echo "  ✅ v3.2" || echo "  ❌ Not v3.2"
grep -q "🟢" docs/WORKFLOW.md 2>/dev/null && echo "  ✅ Status 🟢" || echo "  ❌ Not green"

echo ""
echo "=== STOP IN ALL SKILLS ==="
for skill in build review fix red-team sprint-plan capture-lessons; do
  f=".claude/skills/$skill/SKILL.md"
  [ -f "$f" ] && grep -q "STOP" "$f" && echo "✅ $skill" || echo "❌ $skill"
done
