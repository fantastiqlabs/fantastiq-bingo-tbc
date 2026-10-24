# Issue 2: TBC Anniversary client target

## Decision

Target Burning Crusade Classic Anniversary with TOC interface `20506`, based on current published client references. The target is not confirmed against the owner's live client yet. Verify it with `/dump select(4, GetBuildInfo())` and check Lua errors using [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md).

## Compatibility boundary

The candidate uses Blizzard UI frames, dropdowns, SavedVariables, slash commands, the minimap, and opt-in combat/chat events. RC10 is a test candidate, not a claim of client compatibility. Report any API or behavior mismatch before updating the interface target.

See [RESEARCH_CLIENT_VERSION.md](RESEARCH_CLIENT_VERSION.md) for source notes and uncertainty.
