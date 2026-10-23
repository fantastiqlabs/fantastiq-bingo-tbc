# Raid Bingo Addon implementation candidate

## Status: candidate for owner smoke testing; in-game validation pending

The addon is standalone and targets Burning Crusade Classic Anniversary interface `20506`. It now provides a 5×5 randomized board, a free center, a deck dropdown, and manual local marks. The addon does not detect raid events or verify player claims.

## Implemented for this candidate

- Raid dropdown options for Black Temple, Mount Hyjal, Serpentshrine Cavern, Tempest Keep, Zul'Aman, and Raid Generic.
- 30 Zul'Aman squares spanning Nalorakk, Akil'zon, Jan'alai, Halazzi, Hex Lord Malacrass, and Zul'jin.
- 30 raid-neutral squares without raid or boss names.
- Unique selection for each 24 non-center cell; shorter raid-specific pools may be supplemented from the generic pool.
- Saved board/marks, green click-to-mark state, `/rb new`, `/rb reset`, and a single BINGO yell with a random quote per card.
- `/rb` and `/raidbingo` commands.

## Pending

- Owner smoke test in the actual Anniversary client; no in-game claims are made.
- Lua compilation was unavailable in roost because no Lua runtime/parser is installed.
- Broader catalog count and every legacy square's accuracy remain unaudited.
- ZIP/release checks must be tied to the exact feature commit and clearly marked as an unverified pre-release.

See [INSTALL_GUIDE.md](INSTALL_GUIDE.md) and [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md).
