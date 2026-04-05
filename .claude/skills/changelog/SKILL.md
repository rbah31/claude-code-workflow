---
name: changelog
description: >
  Generate changelogs, release notes, and feature announcements from 
  sprint artifacts. Use when a sprint is complete and needs to be 
  communicated to users. Also use when the user says "changelog", 
  "release notes", "what's new", "announce this", "communicate this 
  feature", "write the update", or after a capture-lessons phase when 
  there are user-facing changes to announce.
---

# Changelog & Release Notes

You generate user-facing communication about what changed in the product.
You read sprint artifacts and translate technical changes into benefits 
users understand.

## Step 1 — Understand what shipped

Read the latest sprint artifacts:
1. `tasks/sprints/sprint-XX/plan.md` — what was planned
2. `tasks/sprints/sprint-XX/build-output.md` — what was built
3. `tasks/sprints/sprint-XX/retrospective.md` — summary
4. `briefs/marketing-context.md` — current positioning and tone

Classify each change:
- **User-facing feature** → goes in the changelog
- **User-facing fix** → goes in the changelog (bug fixes section)
- **Internal/technical** → skip (users don't care about refactors)
- **Security fix** → mention without details ("security improvements")

## Step 2 — Write the changelog

Produce three versions in `content/changelog/sprint-XX/`:

### changelog.md — Full changelog (for the website/docs)

```markdown
# [Product] — [Version or Date]

## New
- **[Feature name]** — [1-2 sentences: what it does, why it matters]

## Improved  
- **[Improvement]** — [what changed, what's better now]

## Fixed
- **[Bug]** — [what was broken, now works correctly]
```

### social-post.md — Short social media version

```markdown
[Emoji] [Product] update:

[1-2 key highlights, punchy, benefit-focused]

[Optional: screenshot or demo link]
```

### discord-announcement.md — Community announcement

```markdown
[Adapted to the community's tone — more casual, more detailed, 
invites feedback]
```

## Step 3 — Tone calibration

Match the product's voice from marketing-context.md:
- **Technical audience** → be specific, mention the how
- **Non-technical audience** → focus on the what and why
- **Community-driven** → invite feedback, celebrate contributors
- **Enterprise** → focus on reliability, security, compliance

## Rules

- Never exaggerate. If it's a small fix, say so
- Never mention security vulnerabilities in detail
- Always frame changes as benefits ("You can now..." not "We added...")
- Include a call to action when relevant ("Try it now", "Let us know")
- If nothing user-facing shipped, don't force a changelog — skip it