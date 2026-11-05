# WoW Forever addon API and leveling Bingo plan

**Research checked:** 2026-11-05
**Tracking issue:** [#100](https://github.com/fantastiqlabs/fantastiq-bingo-tbc/issues/100)

## Recommendation

Treat WoW Forever as a separate modern-client addon target, not as a TBC-compatible variant. Keep the current TBC addon and its release packaging untouched while building the Forever target in its own directory with its own `.toc`, SavedVariables name, version, and archive. Start with local boards and player-marked squares. Add automatic marking only for milestones verified in the live Forever client; do not make combat-log parsing or group-state synchronization a dependency.

## Client and game scope

Blizzard launched WoW Forever on November 4, 2026. The launch announcement describes a level 1–60 journey, over 1,000 quests, and nine new five-player dungeons. It schedules the first three raids for December 9, so a launch-era Bingo board should emphasize leveling, quests, dungeons, and social moments, with raids left as a later content pack. See [Blizzard's launch announcement](https://worldofwarcraft.blizzard.com/en-us/news/24315820/world-of-warcraft-forever-goes-live-globally-4-november).

The latest client capture found during this research identifies the live client on November 3 as version `1.60.1`, build `70755`, interface `16001`, product `wowf`. This is a community-maintained report taken from a local client install, not a measurement of the owner's game installation. Confirm the owner's current build in game before release with `/dump GetBuildInfo()` and `/dump select(4, GetBuildInfo())`. The captured API notes also show that `WOW_PROJECT_ID` is shared with Retail, so it is not enough by itself to tell Forever apart. See [Forever API notes](https://github.com/xIGBClutchIx/ForeverPlusPlus/blob/main/docs/forever-api.md#client-identity).

For the leveling catalog, Blizzard confirms nine new five-player dungeons spanning levels 13–60. [Wowhead's Forever dungeon overview](https://www.wowhead.com/forever/guide/dungeons-overview-locations-details) lists their current names, reported brackets, and regions: Hall of Thanes (13–18), Ruins of Lordaeron (15–20), Excavation Site: Wetlands (24–29), City of Dalaran (28–33), The Drowned City (35–40), Krol'dok Stronghold (40–45), Alcaz Prison (48–53), Blackmaw Hold (55–60), and Shaper's Terrace (58–60). Wowhead cautions that some details remain incomplete or may be inaccurate while testing continues; treat these as catalog leads and verify in-game before relying on the location, level range, or quest details. Blizzard's [launch announcement](https://worldofwarcraft.blizzard.com/en-us/news/24315820/world-of-warcraft-forever-goes-live-globally-4-november) confirms the nine-dungeon launch scope and the overall level 1–60 journey.

The repository currently targets TBC Anniversary interface `20506` in `raid_bingo_addon.toc` and the packaging contract. A Forever package should declare the confirmed Forever interface (`16001` at the date of this research) and must not reuse the TBC SavedVariables key `RaidBingoDB`. Use a distinct addon folder/name and a Forever-specific SavedVariables table to prevent accidental cross-client settings or package installs. The captured client notes report that a plain `.toc` with interface `16001` loads on Forever; verify this against the owner's live client before release.

## API and gameplay constraints

WoW Forever uses the modern UI/API line and inherits its addon restrictions. Blizzard's [combat and addon policy explanation](https://worldofwarcraft.blizzard.com/en-gb/news/24246290) says combat-state data can be exposed as secret values that addons may display but cannot inspect or use for custom logic. The current Forever API notes report that `COMBAT_LOG_EVENT_UNFILTERED` does not fire for addons, and describe health and aura values that may be secret. Therefore:

- Keep click-to-mark as the guaranteed path for every objective.
- Avoid combat-log parsing, health/aura arithmetic, damage checks, and chat parsing as objective detectors.
- A limited auto-mark option can be added for safe, non-combat milestones only after each event and payload is verified in the live client. `PLAYER_LEVEL_UP` is a strong first candidate; achievement and quest events still need direct client verification for this target.
- Keep manual marks private to the player in the first release. Group play can use the same board/content seed on each player's addon, with each player recording their own marks. Do not promise cross-client synchronization until a supported communication path is confirmed for the relevant instance contexts.

Blizzard continues to change the Forever client and API during rollout. The [official November 2 development notes](https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-november-2/2360696) include client and addon compatibility changes. Retest against the actual installed build before release rather than treating interface `16001` or an older beta API dump as permanent.

## Product shape

Keep the first release focused on a collection of replayable 5×5 leveling boards:

| Board family | Example content |
| --- | --- |
| Solo journey | First rare, first dungeon queue or entrance, a memorable quest reward, explore a named region |
| Group journey | Help a party member finish a quest, complete a dungeon with friends, share a campsite or memorable travel moment |
| Dungeon leveling | Bosses, quest completion, first visit, unusual party moment, dungeon-specific discoveries |
| Quest stories | Famous quest lines, escort quests, hidden objectives, story resolutions, memorable NPC interactions |
| Azeroth moments | First mount, unexpected death, unusual drop, getting lost, discovering a scenic place |

Store catalog entries as data with stable IDs and fields for category, board mode, minimum/maximum level, text, optional region/dungeon, and marking policy. The initial catalog is manual-first: every current entry uses `marking = "manual"`, because the Forever event set has not been validated in the owner's live client. A future `verified_event` entry must name the event and only be added after live verification. Keep content separate from UI and card-generation logic. Use a seeded shuffle so a group can select the same board while retaining local mark state. The validator requires at least 25 eligible, unique objectives for both solo and group boards at every ten-level band from 1 through 60.

## Implementation sequence

1. **Compatibility probe:** record the actual client build and `GetBuildInfo()` interface value; confirm a tiny Forever-specific `.toc` loads, SavedVariables persist across reload/restart, and the proposed safe events fire with the expected payloads.
2. **Separate package:** add a dedicated Forever addon directory and `.toc`, a unique SavedVariables name, and a separate deterministic ZIP/release artifact. Keep the existing TBC `20506` package contract and release stream independent.
3. **Catalog and board generation:** define the content schema, solo/group tags, level bands, no-duplicate selection, a deterministic seed, and the existing free-space rules.
4. **Forever UI:** add board-family selection, clear manual mark/unmark controls, a visible board seed/share code, progress display, and local saved board history. Use current client templates and avoid calling protected Blizzard panels from addon code.
5. **Verified milestone support:** add only safe event-driven auto-marks demonstrated in the live client. Persist an audit trail for each mark source so a user can correct a false detection.
6. **Validation and release:** check archive paths and interface metadata in CI, then install on the owner's live Forever client and test solo/group boards, leveling, questing, dungeon entry/completion, SavedVariables persistence, reload, and UI errors. CI packaging is not a substitute for in-client validation.

## Open validation items

- The workspace has no WoW client, so the live build, event registration, TOC load, event payloads, and SavedVariables behavior have not been verified here.
- Verify `PLAYER_LEVEL_UP`, achievement events, and any quest/dungeon completion signals in the owner's current build before enabling auto-marking for them.
- Confirm whether user-to-user board sharing is intended to be local same-seed play or true synchronized progress. Keep synchronized progress out of the first release unless the live client's addon communication rules and APIs are confirmed.
- Decide later whether the repository should be renamed. A separate package target is the lower-risk first step because the existing TBC addon and release are still active.

## Implementation status

Checked 2026-11-05 against the repository main branch:

- Separate Forever package and unique SavedVariables namespace are merged. The package interface remains provisional until the owner's installed client is checked.
- A 73-objective manual-first catalog is merged, including solo/group pools, six level bands, and the nine reported Forever dungeon names/level ranges.
- Seeded 5×5 board generation, a center free square, local per-player marks, board history, and malformed-state recovery are merged. Reopening a mode/range/seed reuses saved marks.
- A native 5×5 board UI is merged with solo/group modes, Adventure/Dungeons/Quest + Story/Memories family selection, six level bands, keyboard/mouse marking, local progress, and shareable seeds. Gamepad behavior and visual rendering still need live-client validation; package CI is not a substitute for loading the addon in Forever.
- Safe automatic marks remain disabled because their events have not been verified in the owner's client.

## Sources

- Blizzard Entertainment, [WoW Forever goes live globally November 4](https://worldofwarcraft.blizzard.com/en-us/news/24315820/world-of-warcraft-forever-goes-live-globally-4-november), published 2026-11-03.
- Blizzard Entertainment, [Combat Philosophy and Addon Disarmament in Midnight](https://worldofwarcraft.blizzard.com/en-gb/news/24246290), official explanation of secret combat values and addon restrictions.
- Blizzard / WoW Forever team, [November 2 development notes](https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-november-2/2360696).
- [ForeverPlusPlus Forever API notes](https://github.com/xIGBClutchIx/ForeverPlusPlus/blob/main/docs/forever-api.md), a community-maintained capture from a local client install. The page identifies build `70755` / interface `16001` on 2026-11-03 and labels evidence as local, in-game, dump, addon-derived, web-reported, or unverified. Treat it as a useful compatibility lead, not an official guarantee.
- [Gethe/wow-ui-source, Forever branch](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated), a mirror of the client UI/API source useful for checking the client-facing names and event documentation; it does not replace an in-game test.
- Repository baseline: [`RESEARCH_CLIENT_VERSION.md`](../../RESEARCH_CLIENT_VERSION.md) and [`raid_bingo_addon.toc`](../../raid_bingo_addon.toc), which document the currently shipped TBC target as interface `20506`.
