# Keeping Claude Code sessions alive

> Prerequisite for remote operations: your Mac needs to stay awake when 
> you leave your desk.

## The setup (5 minutes)

Install Amphetamine from the Mac App Store. Configure Session Defaults 
to prevent system sleep, display sleep, and closed-display sleep. 
Optionally set a battery cutoff at 15%.

Plug your Mac in. Close the lid. The session persists.

That's it.

## Working remotely

Once the Mac stays awake, you have two ways to operate Claude Code 
from your phone:

**Remote Control** (recommended) — Claude Code's built-in feature. 
Run `/remote-control` in an active session, get a URL, open it on your 
phone. Full UI, real-time observation, ability to steer mid-task. 
See the [Remote Control docs](https://code.claude.com/docs/en/remote-control).

**Telegram or Discord via Channels** — Alternative for notification 
workflows or when you want sprint updates pushed to a chat. See the 
[Channels docs](https://code.claude.com/docs/en/channels) for the 
current installation command — plugin syntax may change between releases.

For most use cases: Remote Control is the simpler and more complete 
option. Use it by default. Channels is useful if you already live in 
Telegram/Discord.

## Known tradeoffs

- **Battery drain**: A Mac running with lid closed and system awake 
  consumes notably more than regular sleep. Keep it plugged in for 
  long-running sessions. On battery, set Amphetamine to cut off at 
  15-20%.
- **Thermal**: Reduced heat dissipation with lid closed. Fine for 
  Claude Code (network + light CPU). Don't use this setup for heavy 
  builds or ML workloads with the lid closed.
- **Physical security**: An awake session is an authenticated session. 
  Keep the Mac in a physically secure location.

## Reverting

Quit Amphetamine (menu bar icon → Quit) or delete the app. No system 
files were modified. Your Mac returns to default behavior immediately.

## Advanced: tmux + watchdog for power users

If you want Claude Code sessions to survive terminal crashes and 
auto-restart on failure, tmux with a watchdog cron job works. Setup 
details in `docs/persistent-setup.sh` (optional).