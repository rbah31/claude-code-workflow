#!/usr/bin/env python3
"""PreToolUse hook: block destructive git commands when worktree is dirty.

Triggered for the Bash tool. If the command matches a destructive git
pattern AND `git status --porcelain` is non-empty, exit 1 with a stderr
message explaining how to preserve the worktree first. Otherwise exit 0.

Origin: incident pattern observed in auto-mode sessions where
`git checkout main -- .` (or similar) silently overwrote uncommitted
agent-edited files. This hook closes that brèche by adding a
worktree-aware filter on top of the destructive-pattern denylist.

Destructive patterns covered:
- git checkout -- <path>           overwrites tracked files from index
- git checkout <ref> -- <path>     overwrites tracked files from <ref>
- git restore <path>               overwrites tracked files (default)
- git reset --hard                 wipes worktree to a ref
- git stash drop / clear           erases saved stashes
- git clean -f / -fd / --force     deletes untracked files
- git rm -f / git rm -rf           force-removes tracked files

Explicitly safe (NOT blocked):
- git restore --staged <path>      only un-stages; no worktree write
- git checkout <branch>            switches branch (refuses on conflict)
- git stash push / pop / list      saves or restores; never destroys
- git reset --soft / --mixed       moves HEAD; keeps worktree

Bypass procedure when a destructive op is genuinely needed:
  1. Preserve worktree:  git stash push -m '<reason>'
  2. Re-run the destructive command
  3. Restore later:      git stash pop

Behavior:
- Reads hook input JSON from stdin.
- Allows non-Bash calls (other hooks handle them).
- Allows non-destructive Bash commands.
- Allows destructive commands when worktree is clean.
- Blocks destructive commands when worktree is dirty.

Exit codes:
- 0 = allow
- 1 = block (with stderr message visible to the user and the model)

Fail-open on internal errors (malformed JSON, git unavailable, timeout) —
the hook never breaks the agent because of its own bug. Worst case is the
incident pattern itself, which is the accepted baseline.

Registered in .claude/settings.json under hooks.PreToolUse with matcher
`Bash`.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys


DESTRUCTIVE_PATTERNS: list[re.Pattern[str]] = [
    # git checkout -- <path>   or   git checkout <ref> -- <path>
    re.compile(r"\bgit\s+checkout\s+(?:\S+\s+)?--\s+\S"),
    # git restore <path>       (NOT git restore --staged ...)
    re.compile(r"\bgit\s+restore\s+(?![^&|;]*--staged\b)"),
    # git reset --hard
    re.compile(r"\bgit\s+reset\s+--hard\b"),
    # git stash drop / clear   (push, pop, list, show stay safe)
    re.compile(r"\bgit\s+stash\s+(?:drop|clear)\b"),
    # git clean -f / -fd / --force
    re.compile(r"\bgit\s+clean\s+(?:-[a-zA-Z]*f|--force)\b"),
    # git rm -f / git rm --force
    re.compile(r"\bgit\s+rm\s+(?:-[a-zA-Z]*f|--force)\b"),
]


def is_destructive(command: str) -> bool:
    """Return True if any destructive pattern matches the command."""
    return any(pattern.search(command) for pattern in DESTRUCTIVE_PATTERNS)


def working_tree_dirty() -> bool:
    """Return True iff `git status --porcelain` reports any uncommitted change.

    Fails open (returns False, allowing the command) on subprocess errors —
    the hook should not break the agent because git misbehaved.
    """
    try:
        result = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True,
            text=True,
            check=True,
            timeout=5,
        )
        return bool(result.stdout.strip())
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError):
        return False


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0

    if event.get("tool_name") != "Bash":
        return 0

    command = (event.get("tool_input") or {}).get("command", "") or ""
    if not is_destructive(command):
        return 0

    if not working_tree_dirty():
        return 0

    message = (
        "BLOCKED: destructive git command on a dirty working tree.\n"
        f"Command: {command}\n"
        "\n"
        "The working tree has uncommitted changes. This command would erase\n"
        "them irrecoverably.\n"
        "\n"
        "If the destructive operation is genuinely needed:\n"
        "  1. Preserve worktree:  git stash push -m '<reason>'\n"
        "  2. Re-run the destructive command\n"
        "  3. Restore later:      git stash pop\n"
        "\n"
        "Or commit the pending changes first.\n"
        "\n"
        "If you only wanted to inspect the repo, prefer read-only alternatives:\n"
        "  git status, git diff, git log, git show <ref>:<path>"
    )
    print(message, file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
