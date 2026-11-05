# Fantastiq Bingo TBC

A lightweight, standalone bingo card addon for **World of Warcraft: The Burning Crusade Classic Anniversary**. Open a 5×5 card during a raid and mark moments as they happen. It runs entirely in the WoW client and does not connect to Guildtastiq or any external service.

The current release targets TBC Anniversary. Planning for a separate WoW Forever leveling Bingo target is tracked in [issue #100](https://github.com/fantastiqlabs/fantastiq-bingo-tbc/issues/100) and the [WoW Forever API and content plan](docs/research/wow-forever-addon-api-and-leveling-plan.md). Keep the client package and release target separate until the Forever build has been verified in game.

## What it does

- Deals randomized cards from Raid Generic and mixed Black Temple, Mount Hyjal, Serpentshrine Cavern, Tempest Keep, and Zul'Aman decks. Separate Auto decks use only squares matched by supported combat-log or chat rules; underfilled Auto decks are disabled until their catalog has enough verified events.
- Lets you click squares to mark them; marked squares turn pastel green. New cards include three randomly placed free squares; older saved cards keep their center free square.
- Can optionally match selected combat-log and chat events to squares on the current card. Subjective moments remain manual.
- Provides independent box-size, text-size, and whole-window scale controls, plus a minimap button to show or hide the card.

## Catalog checks

The catalog contains 208 raid-generic squares. Run `lua validate_catalog.lua` from the addon folder to check generic IDs, duplicate text, the 100-square minimum, the 50-character limit, and named raid or boss references.

## Custom decks

Use **Import JSON** to paste a text-only deck or **Export JSON** while a custom
deck is selected. Custom decks are saved locally in the WoW SavedVariables file;
they are not sent to a server. The format accepts only a name and 24–100 unique
prompts (each at most 50 UTF-8 bytes). Imported fields beyond `format`, `version`,
`name`, and `prompts` are rejected. Imported prompts remain plain text and never
define automatic event rules. **Remove custom** deletes only the selected custom
deck; shipped decks and their trigger rules are unchanged.

```json
{"format":"fantastiq-bingo-deck","version":1,"name":"Friends night","prompts":["Someone gets lost","A player says hello"]}
```

The example is abbreviated; a usable deck needs at least 24 unique prompts.

## Install and play

Download the latest [GitHub test release](https://github.com/fantastiqlabs/fantastiq-bingo-tbc/releases/latest), extract `raid_bingo_addon` into your TBC Anniversary `Interface/AddOns` folder, and enable it in the AddOns list. See the [installation guide](INSTALL_GUIDE.md) for details.

Use `/rb` or `/raidbingo` to show or hide the card. Choose a raid from the in-game selector or use `/rb bt`, `/rb hyjal`, `/rb ssc`, `/rb tk`, `/rb za`, or `/rb generic`. Click squares to mark them. Use `/rb new` for another card and `/rb reset` to clear marks. The **Boxes**, **Text**, and **Window** menus adjust the card independently; their settings are saved. Enable **Automark based on events** to use supported observable events.

## Test status

The latest release is a prerelease candidate. Its archive and interface target have been checked, but the addon has not yet been verified in the WoW client. Please run the [smoke-test checklist](SMOKE_TEST_CHECKLIST.md) and report any errors before relying on automarking during a raid. See [WIP_STATUS.md](WIP_STATUS.md) for the current implementation notes.

# WoW Forever compatibility target

The separate `wow_forever/` package is an early compatibility target; the current TBC addon and release remain unchanged. Its interface value `16001` is provisional and must be checked against the installed Forever client before release. The Forever target now includes a native 5×5 board UI with solo/group modes, Adventure/Dungeons/Quest + Story/Memories families, six level bands, manual marks, and a shareable seed. The selected family biases the card toward its category while filling remaining squares from the eligible leveling pool. Dungeon family boards use Group mode and are available only in level bands with dungeon objectives.

In game, run `/dump GetBuildInfo()` and `/dump select(4, GetBuildInfo())`. Record the returned version, build, and interface in the Forever compatibility notes. Then install the Forever ZIP from `dist/`, reload the UI, run `/fqb`, and confirm the SavedVariables entry `FantastiqBingoForeverDB` persists after a client restart. A package/CI pass alone does not establish live-client compatibility.

The catalog lives in `wow_forever/fantastiq_bingo_forever_catalog.lua`; UI code lives in `wow_forever/fantastiq_bingo_forever_ui.lua`; board generation and local persistence live in `wow_forever/fantastiq_bingo_forever_boards.lua`. Entries use stable IDs, category, solo/group modes, a level range, text, optional region/dungeon, and a marking policy. All starter objectives are manual; automatic event marks stay out until verified against the live client. Run `lua5.4 scripts/validate_forever_catalog.lua` to check schema, duplicate IDs/text, and at least 25 eligible squares for solo and group at each level band. Run `lua5.4 scripts/test_forever_boards.lua` to check deterministic seeds, family selection, free space, mode/range filtering, persistence, manual marking, and recovery from malformed data.

Use `/fqb` to open or close the board. Use arrow keys to move the selection and Space/Enter to toggle a manual mark; mouse clicks work on every square. The center free square completes its row, column, and diagonals. Use **New seed** to start a new board, or enter a friend's numeric seed and press Enter to open the same squares. Progress and history stay in the local `FantastiqBingoForeverDB`; there is no addon chat or cross-client state sync. Gamepad behavior and in-game rendering still need validation on the installed Forever client.

The chat shortcut `/fqb solo 11 20 4242` or `/fqb group 31 40 4242` opens a reproducible board directly. The command and UI use the same saved local state.

Build and verify packages independently:

```sh
python3 scripts/package.py --target tbc --output dist
python3 scripts/verify.py dist/raid_bingo_addon_<version>.zip --target tbc
python3 scripts/package.py --target forever --output dist
python3 scripts/verify.py dist/fantastiq_bingo_forever_<version>.zip --target forever
```
