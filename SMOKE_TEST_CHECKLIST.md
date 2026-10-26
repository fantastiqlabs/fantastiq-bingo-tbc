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
- [ ] The Boxes dropdown selects 80%, 100%, and 120%; the Text dropdown selects 5–10, 12, 14, 16, and 18 pt, and long labels still fit.
- [ ] The Window dropdown selects 25%, 50%, 75%, 100%, 125%, and 150%; scale stays within the screen and persists after reload.
- [ ] Changing box size keeps the grid centered, reduces unused frame space, and does not clip selectors, checkbox, or card.
- [ ] The minimap button toggles the card without Lua errors.
- [ ] The saved **Automark based on events** checkbox persists; `/rb automark` toggles it too.
- [ ] With automark enabled during a raid, defeating a boss or killing a named mob on the current card marks the matching square.
- [ ] Taking a listed spell/mechanic hit marks its matching square; an unrelated hit does not mark it.
- [ ] Saying a quoted phrase from a card square in raid/party chat marks that square.
- [ ] `/rb generic` selects the raid-neutral pool; its squares do not name raids or bosses.
- [ ] Raid-specific cards contain a random 2–8 squares for that raid and generic moments in the remaining spaces.
- [ ] The center says FREE and appears marked green.
- [ ] No card contains duplicate squares; shorter raid pools can include generic squares.
- [ ] `/rb new` creates another card; `/rb reset` clears marks.

## Marking and bingo

- [ ] Long square labels wrap and scale down while keeping visible padding inside their cells.
- [ ] The 5×5 grid is centered in a compact window with modest margins and labels remain fully visible at each window scale.
- [ ] Clicking a square changes only its red backdrop to pastel green; clicking it again restores red.
- [ ] The separate frame remains visible and the text color stays the same in both marked and unmarked states.
- [ ] The Automark based on events checkbox and label are centered together above the card.
- [ ] The center cell matches the other cell dimensions, stays green, and centers `FREE`.
- [ ] Marks remain after reloading the UI or relogging with the same card.
- [ ] Completing a horizontal or vertical line yells `BINGO!!!!!!!!!` with one randomly selected Monkey Island-themed quip.
- [ ] The addon performs `/laugh` after the yell.
- [ ] A card yells only once; a new card can announce again.

## Report

- [ ] No Lua or UI errors during deck changes, marking, reset, or reload.
- [ ] Record the client build, steps, and exact errors or unexpected results.
- [ ] Confirm subjective squares without a matching observable event remain manual, and unrelated combat events do not mark squares.
- [ ] `/eventtrace` is diagnostic; combat-log events provide the data the addon matches.

## Release Verification

- [ ] Package was built from the correct commit hash
- [ ] Package contains only expected addon files with correct structure
- [ ] TOC interface version is 20506
- [ ] Package verification script passed successfully
- [ ] Archive contains no duplicate or unsafe paths
- [ ] CRC integrity verified by the package verifier
