# Fantastiq Bingo TBC

A lightweight, standalone bingo card addon for **World of Warcraft: The Burning Crusade Classic Anniversary**. Open a 5×5 card during a raid and mark moments as they happen. It runs entirely in the WoW client and does not connect to Guildtastiq or any external service.

The current release targets TBC Anniversary. Planning for a separate WoW Forever leveling Bingo target is tracked in [issue #100](https://github.com/fantastiqlabs/fantastiq-bingo-tbc/issues/100) and the [WoW Forever API and content plan](docs/research/wow-forever-addon-api-and-leveling-plan.md). Keep the client package and release target separate until the Forever build has been verified in game.

## What it does

- Deals randomized cards from Raid Generic and mixed Black Temple, Mount Hyjal, Serpentshrine Cavern, Tempest Keep, and Zul'Aman decks. Separate Auto decks use only squares matched by supported combat-log or chat rules; underfilled Auto decks are disabled until their catalog has enough verified events.
- Lets you click squares to mark them; marked squares turn pastel green. New cards include three randomly placed free squares; older saved cards keep their center free square.
- Can optionally match selected combat-log and chat events to squares on the current card. Subjective moments remain manual.
- Provides independent box-size, text-size, and whole-window scale controls, plus a minimap button to show or hide the card.

## Catalog checks

The catalog contains 110 raid-generic squares. Run `lua validate_catalog.lua` from the addon folder to check generic IDs, duplicate text, the 100-square minimum, the 50-character limit, and named raid or boss references.

## Install and play

Download the latest [GitHub test release](https://github.com/fantastiqlabs/fantastiq-bingo-tbc/releases/latest), extract `raid_bingo_addon` into your TBC Anniversary `Interface/AddOns` folder, and enable it in the AddOns list. See the [installation guide](INSTALL_GUIDE.md) for details.

Use `/rb` or `/raidbingo` to show or hide the card. Choose a raid from the in-game selector or use `/rb bt`, `/rb hyjal`, `/rb ssc`, `/rb tk`, `/rb za`, or `/rb generic`. Click squares to mark them. Use `/rb new` for another card and `/rb reset` to clear marks. The **Boxes**, **Text**, and **Window** menus adjust the card independently; their settings are saved. Enable **Automark based on events** to use supported observable events.

## Test status

The latest release is a prerelease candidate. Its archive and interface target have been checked, but the addon has not yet been verified in the WoW client. Please run the [smoke-test checklist](SMOKE_TEST_CHECKLIST.md) and report any errors before relying on automarking during a raid. See [WIP_STATUS.md](WIP_STATUS.md) for the current implementation notes.

# WoW Forever compatibility target

The separate `wow_forever/` package is an early compatibility scaffold; the current TBC addon and release remain unchanged. Its interface value `16001` is provisional and must be checked against the installed Forever client before release. The scaffold has a data-driven leveling catalog, but does not yet contain the Bingo board UI.

In game, run `/dump GetBuildInfo()` and `/dump select(4, GetBuildInfo())`. Record the returned version, build, and interface in the Forever compatibility notes. Then install the Forever ZIP from `dist/`, reload the UI, run `/fqb`, and confirm the SavedVariables entry `FantastiqBingoForeverDB` persists after a client restart. A package/CI pass alone does not establish live-client compatibility.

The catalog lives in `wow_forever/fantastiq_bingo_forever_catalog.lua`. Entries use stable IDs, category, solo/group modes, a level range, text, optional region/dungeon, and a marking policy. All starter objectives are manual; automatic event marks stay out until verified against the live client. Run `lua5.4 scripts/validate_forever_catalog.lua` to check schema, duplicate IDs/text, and at least 25 eligible squares for solo and group at each level band.

Build and verify packages independently:

```sh
python3 scripts/package.py --target tbc --output dist
python3 scripts/verify.py dist/raid_bingo_addon_<version>.zip --target tbc
python3 scripts/package.py --target forever --output dist
python3 scripts/verify.py dist/fantastiq_bingo_forever_<version>.zip --target forever
```
