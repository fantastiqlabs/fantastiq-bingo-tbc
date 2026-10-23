# Raid Bingo Addon Smoke Test Checklist

This test is for the Burning Crusade Classic Anniversary client with interface `20506`. The addon has not yet been verified in-game.

## Install and load

- [ ] The main window title reads **Hello There Raid Bingo!**.
- [ ] Extract `raid_bingo_addon` directly under the client's `Interface/AddOns` folder.
- [ ] Enable Raid Bingo from the AddOns list.
- [ ] Load into the world without Lua errors.
- [ ] `/rb` and `/raidbingo` both open the card; `/rb` again hides it.

## Deck selection and cards

- [ ] The dropdown lists Raid Generic, Black Temple, Mount Hyjal, Serpentshrine Cavern, Tempest Keep, and Zul'Aman.
- [ ] Each dropdown choice shows a new 5×5 card.
- [ ] `/rb za` selects Zul'Aman and shows Zul'Aman squares.
- [ ] The Boxes dropdown selects 80%, 100%, and 120%; the Text dropdown selects 5–10 pt and long labels still fit.
- [ ] The minimap button toggles the card without Lua errors.
- [ ] The saved **Automark based on events** checkbox persists; `/rb automark` toggles it too.
- [ ] `/rb generic` selects the raid-neutral pool; its squares do not name raids or bosses.
- [ ] Raid-specific cards contain a random 2–8 squares for that raid and generic moments in the remaining spaces.
- [ ] The center says FREE and appears marked green.
- [ ] No card contains duplicate squares; shorter raid pools can include generic squares.
- [ ] `/rb new` creates another card; `/rb reset` clears marks.

## Marking and bingo

- [ ] Long square labels wrap and scale down while keeping visible padding inside their cells.
- [ ] The larger 5×5 grid is centered in the window and labels remain fully visible.
- [ ] Clicking a square changes only its red interior fill to green; clicking it again restores red.
- [ ] The original Blizzard button frame and text remain unchanged and clearly visible in both marked and unmarked states.
- [ ] The center cell matches the other cell dimensions, stays green, and centers `FREE`.
- [ ] Marks remain after reloading the UI or relogging with the same card.
- [ ] Completing a horizontal or vertical line yells `BINGO!!!!!!!!!` with one randomly selected Monkey Island-themed quip.
- [ ] A card yells only once; a new card can announce again.

## Report

- [ ] No Lua or UI errors during deck changes, marking, reset, or reload.
- [ ] Record the client build, steps, and exact errors or unexpected results.
- [ ] Confirm that squares without explicit verified spell-ID rules remain manual; no broad combat event marks unrelated squares.
- [ ] Use `/eventtrace` and combat-log data during client testing before adding a square's event rule. Note that `/eventtrace` is diagnostic and its history is not directly readable by the addon.
