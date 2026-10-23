# Issue 2: Confirm exact TBC client and addon API target

## Current decision

Target Burning Crusade Classic Anniversary, patch 2.5.6, with TOC interface `20506` based on the current published build reference. `Interface: 11201` was incorrect and has been replaced in `raid_bingo_addon.toc`. See [RESEARCH_CLIENT_VERSION.md](RESEARCH_CLIENT_VERSION.md) for sources and verification limits.

## Compatibility status

This target is not yet confirmed by loading the addon in the owner's client. Verify the live interface number with `/dump select(4, GetBuildInfo())`, then load the addon with Lua errors visible and complete [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md). Revisit the TOC value if the live patch differs.

## API review still needed

Review the APIs used by the addon against the Anniversary client. Confirm slash-command registration, frame creation, saved variables, and combat behavior during the in-game smoke test.
