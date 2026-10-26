# Issue 7: Implementation Roadmap for TBC Anniversary Raid Bingo Addon

## Summary of Decisions

### MVP (Minimum Viable Product)
The addon is a standalone TBC Classic Anniversary tool that provides players with private, locally saved randomized 5×5 bingo cards. Players can mark or unmark cells themselves, Raid-specific cards contain a random 2–8 squares from the selected raid plus generic moments.

### Client/API Baseline
Target Burning Crusade Classic Anniversary with TOC interface `20506`. The addon uses Blizzard UI frames, dropdowns, SavedVariables, slash commands, the minimap, and opt-in combat/chat events. RC10 is a test candidate, not a claim of client compatibility.

### Local Card/Progress Behavior
Each player selects a raid deck and receives a locally randomized card. Card layout and marks persist in that player's SavedVariables. A new card is generated with `/rb new`; marks can be cleared with `/rb reset`. No addon messages are sent and no participant's marks are visible to others.

### Portal Boundary
The Raid Bingo addon is a standalone tool. It does not connect to Hello There Guild, share identity, or send card/mark data to a service. Any future portal handoff or shared raid card requires a new owner-approved design covering identity, consent, data retention, and compatibility.

### Release Workflow
Keep the addon standalone in this repository with Lua modules and `raid_bingo_addon.toc` at the archive root. Target TOC interface `20506`. Publish versioned GitHub prereleases for owner testing. A prerelease is not a stable release or proof of in-client compatibility.

## Roadmap for the Current Candidate

The repository already contains an RC10 test candidate. Keep planning tied to this implementation instead of opening duplicate issues for completed features.

### In RC10; verify in the game client
- Local 5×5 cards, manual square marking, saved settings, and card reset/new-card commands.
- Generic and raid-specific decks for Black Temple, Mount Hyjal, Serpentshrine Cavern, Tempest Keep, and Zul'Aman. Raid-specific cards mix generic squares with a random 2–8 raid-specific squares.
- Independent box-size, text-size, and window-scale selectors. Current options are listed in `SMOKE_TEST_CHECKLIST.md` and implemented in `raid_bingo_ui.lua`.
- An opt-in automark checkbox for supported observable events; subjective moments remain manual.
- The minimap show/hide button.

### Next work
1. Complete the RC10 client smoke test in [issue #23](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/23), using `SMOKE_TEST_CHECKLIST.md`. Until then, describe RC10 as a test candidate, not as client-verified or release-ready.
2. Turn each failed smoke-test item into one focused implementation issue. Give each issue an outcome, acceptance criteria, a narrow file/scope boundary, validation steps, and explicit dependencies. Do not create a broad catch-all issue.
3. Keep compatibility, state migration, and package integrity ahead of optional UI polish. Add new automark rules only for events the client exposes and that can be tested; keep subjective bingo moments manual.
4. After the owner test passes and any resulting fixes are merged, use the existing release workflow to publish the next version. A stable release still requires successful package checks and a clean client smoke test.

### Existing issue map
- [Issue #1](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/1): MVP boundaries and core product behavior.
- [Issue #4](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/4): bingo content, card rules, and raid lifecycle.
- [Issue #5](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/5): standalone addon boundary; no guild-portal integration is needed.
- [Issue #6](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/6): development, test, packaging, and release workflow.
- [Issue #23](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/23): required owner verification in the TBC Anniversary client.

The issue bodies contain the source decisions and task details. If a decision is already recorded there, do not ask the owner to repeat it. There are no agent-blocking dependencies for writing this roadmap; client verification remains an owner task because it requires the game client.

## Minimal Deck Test Plan

For the generic deck and each raid-specific deck (Black Temple, Mount Hyjal, Serpentshrine Cavern, Tempest Keep, and Zul'Aman):
- Select the deck and generate a new card; verify the card contains 25 cells with the free center.
- Confirm raid-specific cards include both generic and raid-specific squares, with 2–8 raid-specific squares.
- Mark and unmark cells, reload the UI, and confirm saved state behaves as described in the smoke checklist.
- For automark, confirm only the documented observable event rules mark cells; keep unverified or subjective events manual.

Use the owner smoke-test issue to record client-only results. Do not record a passing result until it is observed in the target client.
