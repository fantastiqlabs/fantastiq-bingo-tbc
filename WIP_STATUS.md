# Work in progress

The current published prerelease is `v0.1.0-rc.9`. The `v0.1.0-rc.10` candidate tightens the window around the grid and adds saved whole-window scaling (75%, 100%, 125%, 150%). It also retains the separate cell backdrop and border, centered automark control, observable raid-event matching, and `/laugh` after bingo. RC.10 has not been tested in the WoW client.

## Catalog milestone: 30-to-100 raid-generic entries

**Status: ✅ Complete**

The raid-generic pool has been grown from the RC10 baseline of 30 entries to **110 distinct entries** (IDs `generic_001` through `generic_110`). All entries are generic (no raid/boss names or encounter-specific mechanics), have unique IDs, no duplicate text, and pass the source-level validator checks (unique IDs, count ≥100, duplicate text, forbidden terms). The full catalog has 220 total IDs across all pools.

See `raid_bingo_catalog.lua` for the current entries and `validate_catalog.lua` for the validator script.

## Current implementation notes

- Box presets are 80%, 100%, and 120%; text presets are 5–10 pt and long labels shrink further to fit. Whole-window scale presets are 75%, 100%, 125%, and 150%. The grid stays centered and frame height follows grid dimensions to reduce unused space.
- Minimap icon toggles the main card.
- The **Automark based on events** checkbox listens to combat log and chat events only while enabled and during a raid. It matches named boss/mob deaths, explicit player-hit mechanic text, and quoted phrases heard in group chat against squares on the current card.
- The Illidan blue-flame square uses spell ID `40836`; text-driven matching handles other directly named hit squares when the combat log source and spell name match the card wording.
- Unobservable or subjective moments (such as forgetting supplies) remain manual. This is deliberate because combat/chat data cannot reliably prove them.
- Cell colors use separate pastel red/green backdrops and a separate border texture; marking changes only the backdrop. The automark checkbox and its label are positioned as a centered group.
- Completing bingo yells the random quote and then performs `/laugh`.
- `/eventtrace` is useful as a diagnostic while investigating client events; addon code cannot query its displayed event history. A TBC-compatible combat-log viewer confirms that `CombatLogGetCurrentEventInfo()` is used for TBC combat-log inspection.
- The candidate has not been tested inside WoW. Verify selectors, minimap click, checkbox persistence, a known event rule, label fitting, and no Lua errors before treating it as ready for group play.
