# Raid Bingo Addon checkpoint

## Current state

This branch contains an early standalone WoW raid bingo addon with a modular Lua layout, 5×5 card generation, clickable marking, selectable existing raid pools, and an in-game UI. Marks are self-reported and local.

The addon targets Burning Crusade Classic Anniversary. The TOC now uses interface `20506`, corresponding to client patch 2.5.6 in current published client references. No in-game client verification has been performed. See [RESEARCH_CLIENT_VERSION.md](RESEARCH_CLIENT_VERSION.md).

## Not complete

- Zul'Aman is not implemented in the current catalog. Earlier planning notes incorrectly listed Zul'Gurub bosses as Zul'Aman encounters; see [RESEARCH_ZUL_AMAN.md](RESEARCH_ZUL_AMAN.md).
- A distinct raid-generic deck needs verification in code and the UI.
- The catalog size and advertised feature counts have not been independently verified; older “500+” claims are removed from the user-facing summary.
- In-game smoke testing and a verified downloadable release archive are still pending.

## Next steps

1. Implement and review the Zul'Aman and raid-generic pools.
2. Run available static checks and inspect the install archive contents.
3. Owner smoke-test the addon in the Anniversary client and report any Lua/API errors.
4. Package a release candidate after those checks pass.
