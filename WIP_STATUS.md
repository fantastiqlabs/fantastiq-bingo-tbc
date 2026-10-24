# Work in progress

The GitHub Actions release workflow assigns the next `v1.0.0-rc.N` version to each addon-code release and publishes a matching downloadable ZIP. Check [GitHub Releases](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/releases) for the latest candidate. Archive and interface metadata are validated in CI, but the addon has not been verified inside the WoW client.

## Current implementation notes

- Box presets are 80%, 100%, and 120%; text presets are 5–10 pt plus 12, 14, 16, and 18 pt, and long labels shrink further to fit. Whole-window scale presets are 25%, 50%, 75%, 100%, 125%, and 150%. The grid stays centered and frame height follows grid dimensions to reduce unused space.
- Minimap icon toggles the main card.
- The **Automark based on events** checkbox listens to combat log and chat events only while enabled and during a raid. It matches named boss/mob deaths, explicit player-hit mechanic text, and quoted phrases heard in group chat against squares on the current card.
- The Illidan blue-flame square uses spell ID `40836`; text-driven matching handles other directly named hit squares when the combat log source and spell name match the card wording.
- Unobservable or subjective moments (such as forgetting supplies) remain manual. This is deliberate because combat/chat data cannot reliably prove them.
- Cell colors use separate pastel red/green backdrops and a separate border texture; marking changes only the backdrop. The automark checkbox and its label are positioned as a centered group.
- Completing bingo yells the random quote and then performs `/laugh`.
- `/eventtrace` is useful as a diagnostic while investigating client events; addon code cannot query its displayed event history. A TBC-compatible combat-log viewer confirms that `CombatLogGetCurrentEventInfo()` is used for TBC combat-log inspection.
- The candidate has not been tested inside WoW. Verify selectors, minimap click, checkbox persistence, a known event rule, label fitting, and no Lua errors before treating it as ready for group play.
