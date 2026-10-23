# Work in progress

The current published prerelease is `v0.1.0-rc.6`. The active candidate worktree adds separate box-size and actual point-size selectors, a minimap toggle, and an opt-in combat-log matcher.

## Current implementation notes

- Box presets are 80%, 100%, and 120%; text presets are 5–10 pt and long labels shrink further to fit.
- Minimap icon toggles the main card.
- The **Automark based on events** checkbox listens for `COMBAT_LOG_EVENT_UNFILTERED` only while enabled. It matches exact spell IDs declared on catalog squares (`autoMark` metadata) and leaves every other square manual.
- No catalog squares currently have verified `autoMark` spell-ID rules. The feature plumbing is ready, but automatic marking will not happen until rules are validated in the Anniversary client.
- `/eventtrace` is useful as a diagnostic while investigating client events; addon code cannot query its displayed event history. A TBC-compatible combat-log viewer confirms that `CombatLogGetCurrentEventInfo()` is used for TBC combat-log inspection.
- The candidate has not been tested inside WoW. Verify selectors, minimap click, checkbox persistence, a known event rule, label fitting, and no Lua errors before treating it as ready for group play.
