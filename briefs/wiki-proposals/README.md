# briefs/wiki-proposals/

Drop-zone for wiki additions before they enter `wiki/`. Direct writes to
`wiki/**` are blocked by the `block_wiki_write.py` PreToolUse hook —
this folder is the legitimate inbox.

## File naming

```
briefs/wiki-proposals/<YYYY-MM-DD>-<short-slug>.md
```

Example: `briefs/wiki-proposals/2026-05-09-rate-limit-strategy.md`

## File template

```markdown
---
target: wiki/<section>/<page>.md
status: proposed
date: YYYY-MM-DD
source: <where this insight came from — a sprint, an incident, an article, etc.>
---

# <proposed page title>

## Why this belongs in the wiki

<2-3 sentences. What is canonical here that the model wouldn't know
from base training? Why is it stable enough to merge?>

## Proposed content

<the actual page draft — keep it tight, one reason to exist>

## Open questions

<things the human should arbitrate during /wiki-review>
```

## Lifecycle

1. **Proposed** — the file lands here, status `proposed`.
2. **Reviewed** — `/wiki-review` walks each proposal with the human:
   - **Merge** → the human writes the final wiki page (with the
     bypass sentinel `.claude/.wiki-review-active` active for the
     session), the proposal file moves to a dated archive or is
     deleted.
   - **Rewrite** → the human asks for a revised proposal, status
     stays `proposed` with notes.
   - **Discard** → the proposal is deleted with a one-line rationale
     (optional, in `decisions-log.md` if non-trivial).
   - **Defer** → status `deferred`, kept here, revisited next review.
3. **Merged** — the wiki page exists, the proposal is archived or
   removed.

## Discipline

- One idea per proposal. Don't pile multiple sections into one file.
- Source mandatory. If you can't say where the insight came from, it's
  not ready to propose.
- No private context. Anything in `briefs/wiki-proposals/` is going
  toward a public-style canonical wiki — if it's only relevant to your
  current conversation, it's not wiki material yet.
