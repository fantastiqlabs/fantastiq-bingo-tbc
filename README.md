# Raid Bingo Addon

A standalone World of Warcraft: The Burning Crusade Classic Anniversary raid bingo addon.

## Current checkpoint

The project has a modular Lua addon, a 5×5 card UI, a native deck selector, randomized no-duplicate pools, local square marking, and a free center square. Marks are self-reported and local to each player.

RC.1 failed during startup on an Anniversary client because the frame was created without `BackdropTemplate`; that fix is in RC.2. RC.3/RC.4 introduced and enlarged label fitting and green marks ([issue #14](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/14)). RC.5 mixes a random 2–8 raid-specific squares with raid-generic moments ([issue #15](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/15)). RC.6 further expands and centers the board, adds persisted window scale presets ([issue #16](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/16)), and adds more random pirate-adventure victory quips ([issue #17](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/issues/17)). The current worktree replaces whole-window scaling with box-size and point-size menus, adds a minimap toggle, and adds opt-in exact combat-log matching for catalog squares that have verified event rules. These latest changes have not yet been client-tested.

The TOC targets interface `20506` (Burning Crusade Classic Anniversary 2.5.6 in current published client references). No in-game client verification has been performed. See [client target notes](RESEARCH_CLIENT_VERSION.md) and [smoke test checklist](SMOKE_TEST_CHECKLIST.md).

## Current limitations

- Decks can be selected from the in-game dropdown or with `/rb bt`, `/rb hyjal`, `/rb ssc`, `/rb tk`, `/rb za`, and `/rb generic`.
- Raid-specific cards randomly use 2–8 unique raid squares and fill the rest with generic moments. The Raid Generic deck contains only raid-neutral squares.
- Use the Boxes dropdown (80%, 100%, 120%) and Text dropdown (5–10 pt) to adjust the card; both settings persist after reload. Text can shrink below the selected size to fit a long label.
- Click the minimap button to show or hide the card. `/rb` remains available.
- The “Automark based on events” checkbox enables exact combat-log matching. It only marks catalog squares with an explicit verified spell ID; no current catalog square has such a verified rule, so squares currently remain manual. `/rb automark` toggles the option.
- `/eventtrace` is a Blizzard diagnostic window for inspecting fired UI events. It does not provide an event history for addons to query. To add an auto-mark rule, verify the relevant event and spell ID in the Anniversary client and attach an `autoMark` table to the specific catalog square.
- Squares without a verified matching rule are self-reported; no achievements or subjective moments are inferred.
- A GitHub test pre-release is not in-game verified. Complete [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md) and report any errors before treating it as ready for group use.

Open `/rb` or `/raidbingo` to show the card. Click squares to mark them green. Complete a horizontal or vertical line to yell BINGO once for that card, with one random Monkey Island-themed quip. Use `/rb new` to deal a new card, `/rb reset` to clear marks, and `/rb generic` for raid-neutral content. See [INSTALL_GUIDE.md](INSTALL_GUIDE.md) for installation.
