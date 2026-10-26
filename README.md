# Hello There Raid Bingo!

A lightweight, standalone bingo card addon for **World of Warcraft: The Burning Crusade Classic Anniversary**. Open a 5×5 card during a raid and mark moments as they happen. It runs entirely in the WoW client and does not connect to the HelloThereGuild portal or any external service.

## What it does

- Deals randomized cards from Raid Generic, Black Temple, Mount Hyjal, Serpentshrine Cavern, Tempest Keep, and Zul'Aman decks. Raid-specific cards mix in a random handful of encounter moments with general raid bingo squares.
- Lets you click squares to mark them; marked squares turn pastel green. New cards include three randomly placed free squares; older saved cards keep their center free square.
- Can optionally match selected combat-log and chat events to squares on the current card. Subjective moments remain manual.
- Provides independent box-size, text-size, and whole-window scale controls, plus a minimap button to show or hide the card.

## Catalog checks

The catalog contains 110 raid-generic squares. Run `lua validate_catalog.lua` from the addon folder to check generic IDs, duplicate text, the 100-square minimum, the 50-character limit, and named raid or boss references.

## Install and play

Download the latest [GitHub test release](https://github.com/steffenlongva/hellothereguild-raid-bingo-addon/releases/latest), extract `raid_bingo_addon` into your TBC Anniversary `Interface/AddOns` folder, and enable it in the AddOns list. See the [installation guide](INSTALL_GUIDE.md) for details.

Use `/rb` or `/raidbingo` to show or hide the card. Choose a raid from the in-game selector or use `/rb bt`, `/rb hyjal`, `/rb ssc`, `/rb tk`, `/rb za`, or `/rb generic`. Click squares to mark them. Use `/rb new` for another card and `/rb reset` to clear marks. The **Boxes**, **Text**, and **Window** menus adjust the card independently; their settings are saved. Enable **Automark based on events** to use supported observable events.

## Test status

The latest release is a prerelease candidate. Its archive and interface target have been checked, but the addon has not yet been verified in the WoW client. Please run the [smoke-test checklist](SMOKE_TEST_CHECKLIST.md) and report any errors before relying on automarking during a raid. See [WIP_STATUS.md](WIP_STATUS.md) for the current implementation notes.
