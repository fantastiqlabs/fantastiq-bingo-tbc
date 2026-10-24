# Raid Bingo Addon

A standalone World of Warcraft: The Burning Crusade Classic Anniversary raid bingo addon.

## Current checkpoint

The project has a modular Lua addon, a 5×5 card UI, a native deck selector, randomized no-duplicate pools, local square marking, and a free center square. Marking changes only the cell backdrop to pastel green; a separate border stays visible and text color is unchanged.

Earlier prereleases fixed startup, label fitting, card generation, and the raid mix. RC.7 added independent box/text size menus and a minimap toggle. RC.8's inset green fill still touched the cell frame. RC.9 uses a separate cell backdrop and border, a softer green, a centered automark control, event matching against square wording, and a `/laugh` emote after the BINGO yell. The RC.10 candidate tightens the frame around the grid and adds saved whole-window scaling. RC.10 has not yet been client-tested.

The TOC targets interface `20506` (Burning Crusade Classic Anniversary 2.5.6 in current published client references). No in-game client verification has been performed. See [client target notes](RESEARCH_CLIENT_VERSION.md) and [smoke test checklist](SMOKE_TEST_CHECKLIST.md).

## Catalog status

The raid-generic pool contains **110 distinct entries** (IDs `generic_001` through `generic_110`). All entries are generic (no raid/boss names or encounter-specific mechanics), have unique IDs, no duplicate text, and pass the source-level validator checks. The full catalog has 220 total IDs across all pools.

## Current limitations

- Decks can be selected from the in-game dropdown or with `/rb bt`, `/rb hyjal`, `/rb ssc`, `/rb tk`, `/rb za`, and `/rb generic`.
- Raid-specific cards randomly use 2–8 unique raid squares and fill the rest with generic moments. The Raid Generic deck contains only raid-neutral squares.
- Use the Boxes dropdown (80%, 100%, 120%), Text dropdown (5–10 pt), and Window dropdown (75%, 100%, 125%, 150%) to adjust the card. All three settings persist after reload. The frame height follows the grid size, with less empty space around the boxes. Text can shrink below the selected size to fit a long label.
- Marking a cell directly changes its red backdrop to pastel green; the separate frame stays visible and the text color remains the same.
- Click the minimap button to show or hide the card. `/rb` remains available.
- The “Automark based on events” checkbox matches raid combat-log deaths to named boss/mob squares, player-hit combat events to explicit `Get hit by …` squares, and quoted phrases to matching group chat. `/rb automark` toggles it.
- Auto-marking runs only while in a raid and only for squares on the current card. Social moments that depend on interpretation (for example, someone forgetting a reagent) remain manual; chat squares with quoted phrases can match the actual phrase.
- `/eventtrace` is a diagnostic window for inspecting fired UI events; its displayed history is not an addon-queryable event database.
- A GitHub test pre-release is not in-game verified. Complete [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md) and report any errors before treating it as ready for group use.

Open `/rb` or `/raidbingo` to show the card. Click squares to mark them green. Complete a horizontal or vertical line to yell BINGO once for that card, with one random Monkey Island-themed quip, then laugh. Use `/rb new` to deal a new card, `/rb reset` to clear marks, and `/rb generic` for raid-neutral content. See [INSTALL_GUIDE.md](INSTALL_GUIDE.md) for installation.
