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
- Use the **Boxes** dropdown for 80%, 100%, or 120% cell sizes, the **Text** dropdown for 5–10 pt or 12, 14, 16, and 18 pt text, and the **Window** dropdown for 25%, 50%, 75%, 100%, 125%, or 150% overall scale. Text can shrink further when needed to fit a long label. All three settings are saved. The window now trims excess space around the grid and adjusts its height to the chosen cell size.
- Click the minimap icon to show or hide the card. `/rb` and `/raidbingo` also toggle it.
- Enable **Automark based on events** to match raid events against the current card: named boss defeats and mob kills from the combat log, player-hit events for explicit mechanic squares, and exact quoted phrases in group chat. You can also toggle the setting with `/rb automark`.
- Click a square to mark it green; click it again to unmark it. The free center is automatic.
- Complete a horizontal or vertical line to yell `BINGO!!!!!!!!!` with one randomly selected pirate-adventure quip, then perform `/laugh`. The addon announces once per card.
- Use `/rb new` for another random card or `/rb reset` to clear marks.

The Zul'Aman deck has Zul'Aman encounter squares. Each raid-specific card randomly uses 2–8 unique raid squares and fills the remaining spaces with generic moments. The raid-generic deck contains only raid-neutral squares. Auto-marking works only while in a raid and for observable events represented by the current card; subjective/social moments stay manual unless their quoted phrase appears in group chat. `/eventtrace` is a diagnostic window, while combat-log events provide the death and hit details used by the addon.

## Test candidate status

This archive is a pre-release candidate. Automated archive checks do not replace client testing. Follow [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md), record any Lua errors, and report whether the interface, deck selector, marks, and yell work in your client.
