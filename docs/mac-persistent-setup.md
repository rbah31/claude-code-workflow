# Mac Persistent Setup — Claude Code Remote Ops

> Guide to keeping Claude Code sessions alive when the Mac lid is closed
> or the screen is locked. Prerequisite for the Remote Ops workflow.

---

## Why this is necessary

macOS puts the Mac to sleep when the lid is closed or after a period of
inactivity. Claude Code sessions (terminal, Telegram Channel, Remote
Control) die when the Mac sleeps. To operate remotely (Dispatch,
Telegram), the Mac must stay awake.

## What we install

| Tool | Role | Source |
|------|------|--------|
| **Amphetamine** | Prevents sleep (lid closed, screen locked) | Mac App Store (free) |
| **tmux** | Keeps terminal sessions alive in the background | `brew install tmux` |
| **Watchdog cron** | Automatically restarts Claude Code if the session dies | Script included |

No macOS system modifications (no pmset, no system files). Everything is
reversible in 2 minutes.

---

## Step 1 — Install Amphetamine

1. Open the Mac App Store
2. Search for "Amphetamine" (by William Gustafson)
3. Install (free)
4. Launch the app — a ☕ icon appears in the menu bar

### Session Defaults Configuration

Open Amphetamine → Preferences → **Session Defaults**:

| Setting | Value |
|---------|-------|
| Default Duration | **Indefinitely** |
| Forced Sleep | ☐ unchecked |
| Display Sleep | ☐ unchecked |
| Closed-Display Mode | ☐ unchecked ("Allow system sleep when display is closed" = OFF) |
| Screen Saver | ☐ unchecked |
| Battery → End session if charge below | ☑ checked, **15-20%** |
| Battery → Prompt before ending | ☐ unchecked (important: no prompt when lid is closed) |

### General Configuration

Preferences → **General**:

| Setting | Value |
|---------|-------|
| Start Amphetamine at login | ☑ **ON** |

### Create two Triggers

Preferences → **Triggers** → "+" button:

**Trigger 1 — "Mac Home"** (at home, plugged in)

| Field | Value |
|-------|-------|
| Name | Mac Home |
| Criterion | Battery & Power Adapter → "Only when power adapter is connected" |
| Allow display to sleep | ☐ |
| Allow system to sleep when display is closed | ☐ |
| Allow screen saver to run after | ☐ |

**Trigger 2 — "Mac Ext"** (on the go, battery)

| Field | Value |
|-------|-------|
| Name | Mac Ext |
| Criterion | Battery & Power Adapter → "Only when power adapter is not connected" |
| Allow display to sleep | ☐ |
| Allow system to sleep when display is closed | ☐ |
| Allow screen saver to run after | ☐ |

With these two triggers, the Mac stays awake in all situations: plugged
in or not, lid open or closed. On battery, the session ends automatically
at 15-20% to protect the battery.

---

## Step 2 — Run the setup script

```bash
bash docs/mac-persistent-setup.sh
source ~/.zshrc
```

The script installs:
- **Shell aliases**: quick commands to manage sessions
- **Watchdog**: script that checks every 15 min that the session is running
- **Cron**: launches the watchdog automatically
- **tmux config**: long history, mouse support, remain-on-exit

---

## Step 3 — Verify

```bash
claude-status
```

Should display: tmux sessions, Amphetamine status, battery, last monitoring.

---

## Available commands

| Command | What it does |
|---------|-------------|
| `claude-ops` | Launches Claude Code + Telegram in tmux |
| `claude-dev` | Launches Claude Code (without Telegram) in tmux |
| `claude-status` | Checks that everything is running |
| `claude-attach-ops` | Attach to the ops session |
| `claude-attach-dev` | Attach to the dev session |
| `claude-kill` | Stops all sessions cleanly |
| `claude-project DIR` | Changes the project directory |

---

## Daily routine

### Mac at home (plugged in)

```
1. Open a terminal
2. Type: claude-ops
3. Lock the screen (Cmd+Ctrl+Q) or close the lid
4. Walk away — Amphetamine prevents sleep, the watchdog monitors
```

Amphetamine activates automatically via the "Mac Home" trigger (power
adapter detected). You don't have to do anything.

### On the go (battery)

```
1. claude-ops (if not already running)
2. Close the lid
3. The Mac stays awake (trigger "Mac Ext")
4. Amphetamine cuts off at 15% battery — the Mac sleeps, the session dies
5. The watchdog will restart it when the Mac wakes up
```

### From your phone

```
- Dispatch / Remote Control: main tool (full UI)
- Telegram: backup (discretion, future automation)
- Cloud tasks /schedule run independently of the Mac
```

### Verification

```
- Terminal: claude-status
- Telegram: send "briefing" or "/monitoring-briefing"
- Dispatch: same thing via the Claude mobile app
```

### Shutdown

```
- claude-kill → stops the sessions
- Amphetamine → click menu bar icon → End Session (or disable the triggers)
```

---

## Known limitations

**Battery with lid closed**: the Mac consumes more than normal sleep
(CPU + network active). On battery, expect reduced battery life. The 15%
threshold protects the battery but does not replace being plugged in for
prolonged use.

**Thermal**: with the lid closed, heat dissipation is reduced. For
Claude Code (network + light CPU), this is negligible. Not recommended
for heavy builds or ML workloads with the lid closed.

**Watchdog**: if Claude Code crashes in a loop, the watchdog restarts it
every 15 minutes. Not dangerous but check the log from time to time:
`cat ~/.claude-watchdog.log`

**Remote Control**: may lose connection after a long idle even with
Amphetamine. Telegram is more resilient (messages accumulate and execute
when the session resumes).

---

## Full revert

To return to the normal state in 2 minutes:

```bash
# 1. Stop the sessions
claude-kill

# 2. Remove the watchdog cron
crontab -l | grep -v "claude-watchdog" | crontab -

# 3. Remove watchdog files
rm -f ~/.claude-watchdog.sh ~/.claude-watchdog.log

# 4. Amphetamine
# Right-click menu bar icon → Quit
# Or uninstall from the Mac App Store

# 5. Clean up aliases (optional)
# Open ~/.zshrc, remove the "Claude Code persistent sessions" block

# 6. Clean up tmux config (optional)
# Open ~/.tmux.conf, remove the "Claude Code sessions" block
```

Nothing touched the macOS system. No modified pmset, no system files, no
kernel extension. The Mac returns exactly to its original state.

---

## Alternative: VPS

If the Mac setup is not sufficient (unstable sessions, need for 24/7
without a Mac), a Linux VPS (~$5-10/month) is the alternative:

```
VPS Ubuntu (Hetzner, Virtua.cloud, DigitalOcean)
├── Claude Code installed + authenticated
├── tmux permanent session
├── Telegram Channel or mobile SSH access
├── Git repo cloned, AWS CLI configured
└── Runs 24/7 independently of the Mac
```

VPS setup guide: see the community guides referenced in WORKFLOW.md.
Recommended if the Mac persistent setup is not enough or if multiple
production projects require 24/7 availability.
