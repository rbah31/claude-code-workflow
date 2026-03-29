---
name: scaffolding
description: >
  Generate project-specific boilerplate and scaffolding. Use this skill when
  the user wants to create a new module, service, endpoint, command, component,
  migration, or any structural unit that follows the project's patterns. Triggers
  on "new endpoint", "new command", "add a route", "create a component",
  "scaffold", "boilerplate", "new module", "add a migration", "new service".
  Even if the user just says "add a /stats command", use this skill — it knows
  the project's patterns and won't miss auth, tests, or registration steps.
---

# Code Scaffolding

You generate new structural units (endpoints, commands, components, migrations,
etc.) that follow the project's established patterns. The goal is consistency —
every new unit looks like the existing ones, with nothing forgotten.

Read `config.json` in this skill directory for project-specific scaffolding
config. If it doesn't exist, analyze the codebase to discover patterns, then
save what you find for next time.

## How it works

When asked to scaffold something new:

1. **Identify the pattern.** Look at 2-3 existing examples of the same kind
   of unit in the codebase. Note the file structure, naming, imports, boilerplate,
   tests, and registration steps.

2. **Check templates.** Look in `templates/` for pre-built scaffolds. If a
   matching template exists, use it. If not, create one from the pattern you
   discovered for next time.

3. **Generate all pieces.** A new endpoint isn't just a handler — it's the
   handler + route registration + validation + tests + docs update. Generate
   everything the pattern requires.

4. **Verify completeness.** Check that the new unit is registered/imported
   where it needs to be. A handler that exists but isn't routed is invisible.

## Template format

Templates in `templates/` use simple placeholder syntax:

```
# templates/api-endpoint.md
Files to create:
- src/routes/{{name}}.py — handler
- tests/test_{{name}}.py — tests

Pattern to follow: see src/routes/health.py as reference.

Registration: add route in src/app.py

Don't forget:
- Input validation at the boundary
- Auth middleware (unless public)
- Error response shape: { data, error, meta }
- At least one happy-path test
```

Templates are reference docs, not rigid code generators. They tell you what
to create and what not to forget, not exactly how to write it.

## Setup

Create `config.json` after analyzing the project:

```json
{
  "patterns_discovered": {
    "api_endpoint": {
      "example": "src/routes/health.py",
      "files": ["src/routes/{name}.py", "tests/test_{name}.py"],
      "registration": "src/app.py",
      "checklist": ["validation", "auth middleware", "error shape", "test"]
    },
    "bot_command": {
      "example": "src/bot/cogs/help.py",
      "files": ["src/bot/cogs/{name}.py", "tests/test_{name}.py"],
      "registration": "src/bot/main.py",
      "checklist": ["slash command decorator", "permissions", "error handling", "test"]
    }
  }
}
```

Don't create this upfront — build it as you discover patterns. If the user
asks to scaffold something and no config exists, analyze the codebase, scaffold,
and save the pattern.

## Gotchas
- Never scaffold without looking at existing examples first. Consistency > speed.
- The registration step is where most scaffolds break. Always verify the new unit is wired up.
- Don't over-abstract templates. A template with 20 placeholders is harder to use than reading the example code.
- If the project's pattern is bad (no tests, no validation), scaffold it correctly anyway and note the inconsistency.
- Check for name collisions before creating files.

## Memory
After each scaffolding, append to `tasks/scaffolding-history.log`:
```
[YYYY-MM-DD] Created [type]: [name] — [files created]
```
This log helps spot which types are scaffolded most often (candidates for
better templates).