# Migration guide — v3.5.x → v4.0

This guide upgrades an existing v3.5.x project to v4.0. Most changes are
additive and require no behavioral migration. The strategic-pm V2 changes
are behavioral and warrant explicit attention.

> ⏱ **Estimated time**: 15-30 minutes for a typical project.

## Compatibility

- **Compatible with**: any v3.5.x project (v3.5.0, v3.5.1, v3.5.2).
- **Breaking changes**: none on the file format. Two behavioral changes
  on `strategic-pm` (see §3 below).
- **Required Claude Code version**: same as v3.5.x (no new dependency).

## Step 1 — Pull v4.0 files

```bash
git fetch origin
git merge v4.0.0   # or cherry-pick the v4.0.0-prep branch
```

If you forked the OSS template:

```bash
git remote add upstream <template-repo>
git fetch upstream
git merge upstream/main
```

Resolve conflicts on:
- `.claude/CLAUDE.md` — your project-specific content above the new
  cache-hygiene/task-delegation/preferred-tools sections.
- `.claude/settings.json` — your project-specific env vars and deny
  patterns above the new env vars.
- `.claude/agents/strategic-pm.md` — the V2 sections insert cleanly,
  but if you customized this agent locally, review the inserts.

## Step 2 — Add the deployment topology file

Copy the template and fill it with your actual pipeline:

```bash
cp briefs/deployment-topology.template.md briefs/deployment-topology.md
```

Edit `briefs/deployment-topology.md`:
1. List pipeline-covered post-merge actions (auto-deploy, smoke tests, etc.).
2. List manual hors-CI post-merge actions (PO must do these even when CI is green).
3. List pre-merge manual checks the pipeline cannot perform.
4. List auto-rollback triggers.

The PM reads this file at session start. Without it, the wrap-up to the PO
will be incomplete.

## Step 3 — Behavioral changes to expect

### 3.1 — PM stops before `gh pr merge`

In v3.5.x, the strategic-pm chained all phases autonomously and could
auto-merge PRs after `gh pr checks --watch`. In v4.0, the PM stops after
CI watch and waits for the PO to click merge.

**Why**: PMs auto-merging without manual smoke checks introduced
visual/UX regressions that CI couldn't detect.

**What to expect**: after a sprint completes, you (PO) will receive a
wrap-up with:
- PR URL + CI status
- Pre-merge verifications (visual checks, smoke tests, timing)
- Post-merge automatic (pipeline-covered)
- Post-merge manual hors-CI (your action required)
- Pre-S<NEXT> requisites
- Open lessons / non-blocking
- Next sprint readiness

You then click merge yourself when ready.

### 3.2 — `briefs/project-state.md` becomes inter-session bridge

In v3.5.x, project-state.md was loosely updated. In v4.0, the PM
**always** updates it at sprint completion with:
- Sprint status (`merge-pending`, `merged`, etc.)
- Post-merge manual action checklist
- Next-sprint readiness assessment (`actionable | blocked-by: [list]`)

The next session of any agent reads project-state.md first. If marked
`blocked-by: [list]`, the PM will refuse to run `/sprint-plan` until
the blockers are cleared.

**What to expect**: more rigor on cross-session continuity, fewer
sprints opened on false premises.

### 3.3 — CI failure routing splits regression vs pre-existing debt

In v3.5.x, any CI failure auto-routed to `/fix`. In v4.0, the PM
diagnoses first:
- **Sprint-introduced regression** → `/fix` (as before).
- **Pre-existing debt surfaced by CI** (orphan tests, dependency drift,
  scope changes that didn't update tests) → PM proposes 2-3 options to
  you and waits for your decision.

**Why**: auto-routing every failure paved over pre-existing issues.

## Step 4 — Apply the archive convention to existing projects

If your project has > 5 sprints accumulated:

```bash
mkdir -p tasks/sprints/archive
# Move sprints older than the 5 most recent to archive/:
ls tasks/sprints/sprint-* -d | sort -V | head -n -5 | xargs -I {} mv {} tasks/sprints/archive/
```

If your `tasks/backlog.md` has stale completed items:

```bash
touch tasks/backlog-archive.md
# Manual: identify completed items, append to backlog-archive.md with
# format "## [Sprint XX — YYYY-MM-DD] Item title", remove from backlog.md
```

## Step 5 — Verify the hooks

The two new hooks should be wired automatically by the `.claude/settings.json`
merge. Verify:

```bash
# block_wiki_write hook should refuse a write to wiki/test.md:
echo '{"tool_input":{"file_path":"wiki/test.md"}}' | python3 .claude/hooks/block_wiki_write.py
# Expected: stderr message + exit 1

# protect-uncommitted hook should refuse `git reset --hard` if worktree dirty:
echo '{"tool_name":"Bash","tool_input":{"command":"git reset --hard HEAD"}}' | python3 .claude/hooks/protect-uncommitted-hook.py
# Expected (if worktree dirty): stderr message + exit 1
# Expected (if worktree clean): exit 0
```

If the wired hook in `settings.json` references `.claude/hooks/` but the
`.claude/hooks/` directory is missing or the scripts are not executable:

```bash
chmod +x .claude/hooks/*.py
```

## Step 6 — Cache hygiene env vars

The two new env vars in `.claude/settings.json` apply automatically once
you restart your `claude` CLI session:

- `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=80` — auto-compact triggers at 80%
  context instead of 95%. Pair with shorter sessions for best results.
- `CLAUDE_CODE_DISABLE_1M_CONTEXT=1` — 1M context window off; sessions
  are predictable and cheap.

If you previously relied on the 1M window, evaluate whether to keep it
disabled (recommended for most projects) or set the env var to `0` to
re-enable.

## Rollback

If v4.0 introduces friction you didn't expect:

```bash
git revert v4.0.0..HEAD
```

The most common rollback reason in dry-runs has been **CI failure
routing** asking too many "regression vs pre-existing debt" questions
when the project's debt is mostly pre-existing. Solutions:
1. Fix the pre-existing debt in a dedicated chore PR (preferred).
2. Or temporarily revert the V2 PM agent.

## Questions

Open an issue on the OSS repo with the `migration-v4` label.
