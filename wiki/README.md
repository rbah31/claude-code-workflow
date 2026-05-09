# wiki/

Project-specific knowledge that's stable enough to be canonical. The
**model adapted to your project** — generic LLM base knowledge plus what
is yours.

The wiki is empty in the template. As you ship sprints, capture what
the model couldn't know on its own: domain rules, recurring incidents,
the specific reason this codebase makes the choices it makes,
terminology that exists nowhere else.

## How to populate

1. **Don't write here directly.** Agents are blocked from `wiki/**` by
   the `block_wiki_write.py` PreToolUse hook. The hook is intentional
   — auto-ingested wiki content drifts the wiki into another
   conversation buffer.

2. **Agents propose via `briefs/wiki-proposals/<date>-<slug>.md`.** A
   capture worth promoting starts as a proposal (one file, one idea,
   sourced and dated).

3. **Run `/wiki-review` to arbitrate.** The skill walks each proposal
   with you (merge / rewrite / discard / defer), creates the bypass
   sentinel `.claude/.wiki-review-active` for the duration of the
   merge, and removes it at end of run. This is the single legitimate
   path through the gate.

4. **You write or edit the wiki yourself**, with the proposal in front
   of you. Keep it concise. One page = one reason to exist.

## Suggested structure (build as needed)

The structure emerges from your project. Some suggestions that recur:

```
wiki/
├── architecture/        # how the system is laid out, what talks to what
├── domain/              # business rules, terminology, edge cases
├── conventions/         # decisions you keep making the same way
├── incidents/           # postmortems and what they taught us
└── references/          # external sources the project depends on
```

Don't pre-create empty folders. Add a section the first time you have
one real page to put in it. An empty `wiki/` is fine — it just means
the model is operating on its base knowledge plus `CLAUDE.md`. The
wiki grows when there's something worth keeping.

## What does *not* belong here

- **Conversation transcripts** — the wiki is curated, not logged.
- **Sprint artefacts** — those live in `tasks/sprints/sprint-XX/`.
- **Strategic agent state** — that lives in `briefs/`.
- **Personal notes** — keep those in `CLAUDE.local.md` (gitignored).
- **Anything you wouldn't link to from a code review** — if it's not
  something you'd cite as authoritative, it's not wiki material yet.

## Cross-reference

- `docs/WORKFLOW.md` §6 — *Wiki — your model adapted* (the framing).
- `.claude/skills/wiki-review/SKILL.md` — the review gate procedure.
- `.claude/hooks/block_wiki_write.py` — the deterministic guard.
