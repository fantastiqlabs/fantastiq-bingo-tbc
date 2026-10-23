# Raid Bingo Addon Smoke Test Checklist

This test is for the Burning Crusade Classic Anniversary client with interface `20506`. The addon has not yet been verified in-game.

## Install and load

- [ ] Extract `raid_bingo_addon` directly under the client's `Interface/AddOns` folder.
- [ ] Enable Raid Bingo from the AddOns list.
- [ ] Load into the world without Lua errors.
- [ ] `/rb` and `/raidbingo` both open the card; `/rb` again hides it.

## Deck selection and cards

- [ ] The dropdown lists Raid Generic, Black Temple, Mount Hyjal, Serpentshrine Cavern, Tempest Keep, and Zul'Aman.
- [ ] Each dropdown choice shows a new 5×5 card.
- [ ] `/rb za` selects Zul'Aman and shows Zul'Aman squares.
- [ ] `/rb generic` selects the raid-neutral pool; its squares do not name raids or bosses.
- [ ] Raid-specific cards contain both that raid's encounter squares and raid-generic moments.
- [ ] The center says FREE and appears marked green.
- [ ] No card contains duplicate squares; shorter raid pools can include generic squares.
- [ ] `/rb new` creates another card; `/rb reset` clears marks.

## Marking and bingo

- [ ] Long square labels wrap and scale down while keeping visible padding inside their cells.
- [ ] Clicking a square marks it green; clicking it again clears it.
- [ ] Marked cells look green rather than dark red under the client theme.
- [ ] Marks remain after reloading the UI or relogging with the same card.
- [ ] Completing a horizontal or vertical line yells `BINGO!!!!!!!!!` with a random quote.
- [ ] A card yells only once; a new card can announce again.

## Report

- [ ] No Lua or UI errors during deck changes, marking, reset, or reload.
- [ ] Record the client build, steps, and exact errors or unexpected results.
- [ ] Confirm that square marks are manual/self-reported; no encounter events are claimed as detected.
