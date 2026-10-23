# Raid Bingo Addon Installation Guide

## Requirements

- World of Warcraft: The Burning Crusade Classic Anniversary, interface `20506`.
- A downloadable GitHub test pre-release of Raid Bingo.
- In-game compatibility is not verified yet. Run the smoke checklist after installing.

## Install

1. Close World of Warcraft.
2. Open the AddOns folder for the Anniversary client:
   - Windows: `World of Warcraft\_classic_\Interface\AddOns`
   - macOS: `/Applications/World of Warcraft/_classic_/Interface/AddOns`
3. Extract the ZIP so the folder `raid_bingo_addon` is directly inside `AddOns`, with `raid_bingo_addon.toc` inside it.
4. Start the game, enable Raid Bingo on the character select AddOns screen, and enter the world.

## Use

- Type `/rb` or `/raidbingo` to show or hide the card.
- Choose a deck from the dropdown, or use `/rb bt`, `/rb hyjal`, `/rb ssc`, `/rb tk`, `/rb za`, or `/rb generic`.
- Click a square to mark it green; click it again to unmark it. The free center is automatic.
- Complete a horizontal or vertical line to yell `BINGO!!!!!!!!!` with a random joke. The addon announces once per card.
- Use `/rb new` for another random card or `/rb reset` to clear marks.

The Zul'Aman deck has Zul'Aman encounter squares. Each raid-specific card randomly uses 2–8 unique raid squares and fills the remaining spaces with generic moments. The raid-generic deck contains only raid-neutral squares. Marks are private and self-reported; the addon does not detect encounter events or verify achievements.

## Test candidate status

This archive is a pre-release candidate. Automated archive checks do not replace client testing. Follow [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md), record any Lua errors, and report whether the interface, deck selector, marks, and yell work in your client.
