# Raid Bingo Addon

A standalone World of Warcraft: The Burning Crusade Classic Anniversary raid bingo addon.

## Current checkpoint

The project has a modular Lua addon scaffold, a 5×5 card UI, selectable catalog pools, local square marking, and a free center square. Marks are self-reported and local to each player.

The TOC targets interface `20506` (Burning Crusade Classic Anniversary 2.5.6 in current published client references). No in-game client verification has been performed. See [client target notes](RESEARCH_CLIENT_VERSION.md) and [smoke test checklist](SMOKE_TEST_CHECKLIST.md).

## Current limitations

- Zul'Aman is planned but not implemented in the Lua catalog.
- A raid-generic deck is planned; the catalog and UI still need verification that it is available as a selectable pool.
- Catalog size and the old advertised square counts have not been verified.
- No release archive has been verified for installation.

See [FINAL_SUMMARY.md](FINAL_SUMMARY.md) for the next steps and [INSTALL_GUIDE.md](INSTALL_GUIDE.md) for a preliminary install guide.
