#!/usr/bin/env python3
"""PreToolUse hook: block direct writes to wiki/** from agents.

The wiki is curated by humans via the /wiki-review skill. Agents must
propose additions to `briefs/wiki-proposals/` instead of writing directly.

Behavior:
- Reads the hook input JSON from stdin (tool_input contains file_path).
- If the target path is inside `wiki/`, exit 1 with a guidance message.
- Otherwise, exit 0 (allow).

Humans editing the wiki manually do not go through this hook — it only
fires inside Claude Code Write/Edit tool calls.

Bypass: the /wiki-review skill creates `.claude/.wiki-review-active`
while merging proposals into wiki/. When the sentinel file exists, this
hook allows wiki/ writes so the skill can do its job. The skill removes
the sentinel at end of run (success or interruption).

Registered in .claude/settings.json under hooks.PreToolUse with matcher
`Write|Edit`.
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path


def _resolve_project_root() -> Path:
    """Best-effort project root: walk up from CWD looking for .claude/."""
    cwd = Path(os.getcwd()).resolve()
    for candidate in [cwd, *cwd.parents]:
        if (candidate / ".claude").is_dir():
            return candidate
    return cwd


def _is_wiki_path(file_path: str, project_root: Path) -> bool:
    """Return True if file_path targets wiki/** under the project root."""
    if not file_path:
        return False

    try:
        absolute = Path(file_path).resolve()
    except (OSError, RuntimeError):
        return False

    try:
        relative = absolute.relative_to(project_root)
    except ValueError:
        # Outside project root — not our concern here.
        return False

    parts = relative.parts
    return len(parts) > 0 and parts[0] == "wiki"


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        # Malformed input — allow rather than block (fail-open for user).
        return 0

    tool_input = payload.get("tool_input") or {}
    file_path = tool_input.get("file_path") or ""

    project_root = _resolve_project_root()

    # Bypass sentinel: `/wiki-review` skill creates `.claude/.wiki-review-active`
    # while merging proposals into wiki/. When the sentinel exists, allow
    # wiki/ writes so the skill can do its job.
    if (project_root / ".claude" / ".wiki-review-active").is_file():
        return 0

    if not _is_wiki_path(file_path, project_root):
        return 0

    message = (
        "BLOCKED: direct writes to wiki/** are forbidden for agents.\n"
        "The wiki is curated by humans via the /wiki-review skill.\n"
        "To propose an addition, create a draft under\n"
        "  briefs/wiki-proposals/YYYY-MM-DD-HHMM-<slug>.md\n"
        "and the human will merge it during /wiki-review."
    )
    print(message, file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
