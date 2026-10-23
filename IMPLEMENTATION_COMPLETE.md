# Raid Bingo Addon implementation checkpoint

## Status: early checkpoint; not release-ready

The repository contains an initial standalone addon implementation with Lua modules for card generation, catalog data, UI, and utility logic. The visible feature set and compatibility still need owner-side game testing.

## Present in the code

- 5×5 card layout with a free center square
- Clickable local square marking
- Modular Lua files and addon TOC metadata
- Several catalog pools and basic random card generation

## Known gaps

- Zul'Aman is planned but not present in the current Lua catalog. Earlier notes confused Zul'Aman with Zul'Gurub; see `RESEARCH_ZUL_AMAN.md`.
- The generic pool design is documented, but its selectable implementation needs verification.
- Catalog size and previously advertised per-raid counts are unverified.
- Client target is set to Interface `20506` from current published references; in-game compatibility is unverified.
- The install guide and package still need review against the owner's actual client.

## Next step

Complete [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md) in the Burning Crusade Classic Anniversary client, record any API or UI errors, then finish and validate the planned decks before preparing a release candidate.
