# Raid Bingo Addon

A standalone World of Warcraft: The Burning Crusade Classic Anniversary raid bingo addon.

## Current checkpoint

The project has a modular Lua addon, a 5×5 card UI, a native deck selector, randomized no-duplicate pools, local square marking, and a free center square. Marks are self-reported and local to each player.

RC.1 failed during startup on an Anniversary client because the frame was created without `BackdropTemplate`; that fix is in RC.2. RC.3/RC.4 introduced and enlarged label fitting and green marks ([issue #14](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/14)). RC.5 mixes a random 2–8 raid-specific squares with raid-generic moments ([issue #15](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/15)). RC.6 further expands and centers the board and adds persisted window scale presets ([issue #16](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/16)). Use the latest prerelease for testing.

The TOC targets interface `20506` (Burning Crusade Classic Anniversary 2.5.6 in current published client references). No in-game client verification has been performed. See [client target notes](RESEARCH_CLIENT_VERSION.md) and [smoke test checklist](SMOKE_TEST_CHECKLIST.md).

## Current limitations

- Decks can be selected from the in-game dropdown or with `/rb bt`, `/rb hyjal`, `/rb ssc`, `/rb tk`, `/rb za`, and `/rb generic`.
- Raid-specific cards randomly use 2–8 unique raid squares and fill the rest with generic moments. The Raid Generic deck contains only raid-neutral squares.
- Click the percentage button to cycle window sizes; use `/rb scale 25`, `/rb scale 50`, `/rb scale 75`, `/rb scale 100`, `/rb scale 125`, or `/rb scale 150` to choose a size directly. Your selection persists after reload.
- Squares are self-reported; the addon does not detect encounter events or verify achievements.
- A GitHub test pre-release is not in-game verified. Complete [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md) and report any errors before treating it as ready for group use.

Open `/rb` or `/raidbingo` to show the card. Click squares to mark them green. Complete a horizontal or vertical line to yell BINGO once for that card. Use `/rb new` to deal a new card, `/rb reset` to clear marks, and `/rb generic` for raid-neutral content. See [INSTALL_GUIDE.md](INSTALL_GUIDE.md) for installation.
