#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Mac Persistent Claude Code — Setup v2
# Amphetamine gère le sleep. Ce script gère le reste.
# ═══════════════════════════════════════════════════════════

echo "═══ SETUP MAC PERSISTENT CLAUDE CODE v2 ═══"
echo ""

# ─── 1. VÉRIFICATIONS ───
echo "══ 1. Vérifications ══"

command -v tmux &>/dev/null && echo "  ✅ tmux installé" || echo "  ❌ tmux manquant — brew install tmux"
command -v bun &>/dev/null && echo "  ✅ bun installé" || echo "  ❌ bun manquant — curl -fsSL https://bun.sh/install | bash"
command -v claude &>/dev/null && echo "  ✅ claude installé" || echo "  ❌ claude manquant"

# Vérifier Amphetamine
if ls /Applications/Amphetamine.app &>/dev/null || mdfind "kMDItemCFBundleIdentifier == 'com.if.Amphetamine'" 2>/dev/null | grep -q "."; then
  echo "  ✅ Amphetamine installé"
else
  echo "  ❌ Amphetamine manquant — installe depuis le Mac App Store (gratuit)"
  echo "     https://apps.apple.com/app/amphetamine/id937984704"
fi

echo ""

# ─── 2. ALIAS SHELL ───
echo "══ 2. Alias shell ══"

SHELL_RC="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && ! [ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.bashrc"

if ! grep -q "claude-ops" "$SHELL_RC" 2>/dev/null; then
  cat >> "$SHELL_RC" << 'ALIASES'

# ─── Claude Code persistent sessions ───
# Adapte le chemin du projet si nécessaire
CLAUDE_PROJECT_DIR="$HOME/Documents/Dev/my-project"

alias claudet='claude --channels plugin:telegram@claude-plugins-official'

# Lance la session ops (Telegram) dans tmux
claude-ops() {
  if tmux has-session -t ops 2>/dev/null; then
    echo "⚠️  Session ops déjà active. Utilise claude-attach-ops pour t'y connecter."
    return 1
  fi
  cd "$CLAUDE_PROJECT_DIR"
  tmux new-session -d -s ops "claude --channels plugin:telegram@claude-plugins-official"
  echo "✅ Session ops lancée dans tmux"
  echo "   Projet : $CLAUDE_PROJECT_DIR"
  echo "   Telegram : actif"
  echo "   Pour voir : claude-attach-ops"
}

# Lance la session dev dans tmux
claude-dev() {
  if tmux has-session -t dev 2>/dev/null; then
    echo "⚠️  Session dev déjà active. Utilise claude-attach-dev pour t'y connecter."
    return 1
  fi
  cd "$CLAUDE_PROJECT_DIR"
  tmux new-session -d -s dev "claude"
  echo "✅ Session dev lancée dans tmux"
}

# Vérifie tout d'un coup
claude-status() {
  echo "═══ CLAUDE STATUS ═══"
  echo ""
  echo "── Sessions tmux ──"
  tmux ls 2>/dev/null || echo "  Aucune session active"
  echo ""
  echo "── Amphetamine ──"
  if pgrep -x "Amphetamine" >/dev/null; then
    echo "  ✅ Amphetamine tourne"
  else
    echo "  ❌ Amphetamine n'est pas lancé"
  fi
  echo ""
  echo "── Batterie ──"
  pmset -g batt | head -2
  echo ""
  echo "── Dernier monitoring ──"
  if [ -f "$CLAUDE_PROJECT_DIR/monitoring/daily-brief-latest.md" ]; then
    head -3 "$CLAUDE_PROJECT_DIR/monitoring/daily-brief-latest.md"
  else
    echo "  Pas de daily brief trouvé"
  fi
}

alias claude-attach-ops='tmux attach -t ops'
alias claude-attach-dev='tmux attach -t dev'

# Arrête tout proprement
claude-kill() {
  tmux kill-session -t ops 2>/dev/null && echo "✅ Session ops arrêtée" || echo "  Pas de session ops"
  tmux kill-session -t dev 2>/dev/null && echo "✅ Session dev arrêtée" || echo "  Pas de session dev"
  echo "💡 Pense à désactiver Amphetamine si tu n'en as plus besoin"
}

# Change de projet pour les sessions
claude-project() {
  if [ -z "$1" ]; then
    echo "Usage: claude-project ~/chemin/vers/projet"
    echo "Projet actuel : $CLAUDE_PROJECT_DIR"
    return 1
  fi
  export CLAUDE_PROJECT_DIR="$1"
  echo "✅ Projet changé : $CLAUDE_PROJECT_DIR"
}
ALIASES
  echo "  ✅ Alias ajoutés dans $SHELL_RC"
else
  echo "  ✅ Alias déjà présents"
fi

echo ""
echo "  Commandes disponibles :"
echo "    claude-ops         → Lance session Telegram dans tmux"
echo "    claude-dev         → Lance session dev dans tmux"
echo "    claude-status      → Vérifie que tout tourne"
echo "    claude-attach-ops  → Se connecter à la session ops"
echo "    claude-attach-dev  → Se connecter à la session dev"
echo "    claude-kill        → Arrêter toutes les sessions"
echo "    claude-project DIR → Changer de projet"
echo ""

# ─── 3. WATCHDOG ───
echo "══ 3. Script watchdog ══"

cat > "$HOME/.claude-watchdog.sh" << 'WATCHDOG'
#!/bin/bash
# Vérifie que la session ops tourne, redémarre si morte
# Lancé par cron toutes les 15 minutes

LOG="$HOME/.claude-watchdog.log"
DATE=$(date '+%Y-%m-%d %H:%M')
PROJECT_DIR="$HOME/Documents/Dev/my-project"

# Vérifier si tmux session ops existe
if tmux has-session -t ops 2>/dev/null; then
  echo "$DATE — ✅ ops running" >> "$LOG"
else
  # Vérifier si Amphetamine tourne (sinon pas la peine de relancer)
  if ! pgrep -x "Amphetamine" >/dev/null; then
    echo "$DATE — ⚠️ ops dead, Amphetamine not running, skipping restart" >> "$LOG"
    exit 0
  fi

  echo "$DATE — ❌ ops dead, restarting" >> "$LOG"
  cd "$PROJECT_DIR"
  tmux new-session -d -s ops "claude --channels plugin:telegram@claude-plugins-official"
  echo "$DATE — 🔄 ops restarted" >> "$LOG"

  # Notification macOS
  osascript -e 'display notification "Session ops redémarrée automatiquement" with title "Claude Watchdog"' 2>/dev/null
fi

# Garder le log à 200 lignes max
tail -200 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
WATCHDOG

chmod +x "$HOME/.claude-watchdog.sh"
echo "  ✅ Watchdog créé : ~/.claude-watchdog.sh"

echo ""

# ─── 4. CRON ───
echo "══ 4. Cron watchdog ══"

CRON_LINE="*/15 * * * * $HOME/.claude-watchdog.sh"
if crontab -l 2>/dev/null | grep -q "claude-watchdog"; then
  echo "  ✅ Cron déjà configuré"
else
  (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
  echo "  ✅ Cron ajouté : vérification toutes les 15 minutes"
fi

echo ""

# ─── 5. TMUX CONFIG ───
echo "══ 5. Configuration tmux ══"

TMUX_CONF="$HOME/.tmux.conf"
if [ ! -f "$TMUX_CONF" ] || ! grep -q "claude" "$TMUX_CONF" 2>/dev/null; then
  cat >> "$TMUX_CONF" << 'TMUX'

# ─── Claude Code sessions ───
set -g history-limit 50000
set -g mouse on
set -g status-right '#[fg=green]#S #[fg=white]| #[fg=yellow]%H:%M'
# Garder la session tmux si le process crash
set -g remain-on-exit on
# Couleurs correctes
set -g default-terminal "screen-256color"
TMUX
  echo "  ✅ tmux.conf configuré"
else
  echo "  ✅ tmux.conf déjà configuré"
fi

echo ""

# ─── 6. RÉSUMÉ ───
echo "══════════════════════════════════════════"
echo "  SETUP TERMINÉ"
echo "══════════════════════════════════════════"
echo ""
echo "  ⚠️  Recharge ton shell : source $SHELL_RC"
echo ""
echo "  ┌─────────────────────────────────────────────┐"
echo "  │  ROUTINE — MAC À LA MAISON (branché)        │"
echo "  │                                             │"
echo "  │  1. Ouvre Amphetamine → Indefinitely        │"
echo "  │  2. Terminal → claude-ops                   │"
echo "  │  3. Ferme le lid ou verrouille (Cmd+Ctrl+Q) │"
echo "  │  4. Pars — le watchdog surveille            │"
echo "  │                                             │"
echo "  │  ROUTINE — EN DÉPLACEMENT (batterie)        │"
echo "  │                                             │"
echo "  │  1. Amphetamine → Battery trigger activé    │"
echo "  │  2. Terminal → claude-ops                   │"
echo "  │  3. Ferme le lid — le Mac reste éveillé     │"
echo "  │  4. Amphetamine coupe à 20% batterie        │"
echo "  │                                             │"
echo "  │  VÉRIFICATION                               │"
echo "  │  → claude-status (depuis le terminal)       │"
echo "  │  → Envoie 'bilan' sur Telegram (à distance) │"
echo "  │                                             │"
echo "  │  ARRÊT                                      │"
echo "  │  → claude-kill                              │"
echo "  │  → Désactive Amphetamine                    │"
echo "  └─────────────────────────────────────────────┘"
echo ""
echo "══════════════════════════════════════════"