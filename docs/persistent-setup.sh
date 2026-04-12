#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Claude Code persistent sessions — optional setup
# ═══════════════════════════════════════════════════════════
# Adds tmux aliases so Claude Code sessions survive terminal
# crashes and can be re-attached from anywhere.
#
# Prerequisite: Amphetamine (or equivalent) keeps the Mac awake.
# See docs/mac-persistent-setup.md for the full context.
#
# Most users do not need this script — Remote Control is the
# recommended way to operate Claude Code remotely. This script
# is for power users who want tmux-backed sessions in addition.
# ═══════════════════════════════════════════════════════════

set -e

echo "═══ Claude Code tmux aliases — setup ═══"
echo ""

# ─── 1. Check dependencies ───
command -v tmux >/dev/null 2>&1 || {
  echo "✗ tmux not found. Install with: brew install tmux"
  exit 1
}
command -v claude >/dev/null 2>&1 || {
  echo "✗ claude not found. Install Claude Code first."
  exit 1
}
echo "✓ tmux and claude available"

# ─── 2. Detect shell config file ───
SHELL_RC="$HOME/.zshrc"
if [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.bashrc"
fi
echo "✓ will append aliases to $SHELL_RC"

# ─── 3. Add aliases (idempotent) ───
if grep -q "# ── Claude Code persistent sessions ──" "$SHELL_RC" 2>/dev/null; then
  echo "✓ aliases already present, skipping"
else
  cat >> "$SHELL_RC" <<'ALIASES'

# ── Claude Code persistent sessions ──
# CLAUDE_PROJECT_DIR defaults to current working directory when the
# alias is called. Override by exporting CLAUDE_PROJECT_DIR=/path/to/repo
# in your shell, or by running `claude-project /path` (defined below).

claude-tmux() {
  local session="${1:-main}"
  local dir="${CLAUDE_PROJECT_DIR:-$PWD}"
  if tmux has-session -t "$session" 2>/dev/null; then
    echo "Session '$session' already exists. Attach: tmux attach -t $session"
    return 1
  fi
  cd "$dir" && tmux new-session -d -s "$session" "claude"
  echo "✓ Started tmux session '$session' in $dir"
  echo "  Attach:  tmux attach -t $session"
  echo "  Detach:  Ctrl+b then d"
  echo "  Kill:    tmux kill-session -t $session"
}

claude-project() {
  if [ -z "$1" ]; then
    echo "Current project: ${CLAUDE_PROJECT_DIR:-$PWD}"
    echo "Usage: claude-project /path/to/repo"
    return 0
  fi
  export CLAUDE_PROJECT_DIR="$1"
  echo "✓ CLAUDE_PROJECT_DIR set to $CLAUDE_PROJECT_DIR"
}
ALIASES
  echo "✓ aliases added"
fi

echo ""
echo "Done. Reload your shell: source $SHELL_RC"
echo ""
echo "Usage:"
echo "  claude-tmux              # start session 'main' in current directory"
echo "  claude-tmux ops          # start session 'ops'"
echo "  claude-project /path     # change default project dir"
echo "  tmux attach -t main      # attach to a session"
echo "  tmux ls                  # list sessions"