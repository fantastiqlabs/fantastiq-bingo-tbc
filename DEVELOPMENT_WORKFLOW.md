# Development, Testing, Packaging, and Release Workflow

## Repository Layout and Structure

The addon is structured as a standalone WoW addon with the following layout:
- Root folder: `raid_bingo_addon`
- TOC file: `raid_bingo_addon.toc` (at archive root)
- Main Lua modules:
  - `raid_bingo_addon.lua` - Main addon logic and initialization
  - `raid_bingo_card.lua` - Card generation and management
  - `raid_bingo_ui.lua` - User interface components
  - `raid_bingo_utils.lua` - Utility functions
  - `raid_bingo_catalog.lua` - Card catalog data

## TOC Metadata and Version Strategy

- **Interface version**: 20506 (The Burning Crusade Anniversary client)
- **Versioning strategy**: 
  - Use sequential `v0.1.0-rc.N` tags for test candidates
  - Promote to stable version only after owner confirms in-game compatibility
  - Version numbers should be incremented with each release candidate

## License Approach

The addon is licensed under a permissive open source license (to be determined) that allows:
- Free use and distribution
- Modification and redistribution
- Commercial use
- Attribution requirements

## Static Checks and Lua Tests

### Available Static Checks
- Run `lua validate_catalog.lua` to check catalog rules:
  - Generic IDs validation
  - Duplicate text detection
  - Minimum 100-square requirement
  - 50-character limit enforcement
  - Named raid/boss references validation

### Automated Testing
- The repository includes Python scripts for package verification:
  - `scripts/verify.py` - Validates package structure and contents
  - `scripts/test_package_verification.py` - Unit tests for package verification
  - `scripts/package_contract.py` - Defines package contract requirements
  - `scripts/package.py` - Package building utilities

## In-Client Validation Checklist

The owner must complete the following checklist in the WoW client before claiming compatibility:

### Install and Load
- [ ] The main window title reads **Hello There Raid Bingo!**
- [ ] Extract `raid_bingo_addon` directly under the client's `Interface/AddOns` folder
- [ ] Enable Raid Bingo from the AddOns list
- [ ] Load into the world without Lua errors
- [ ] `/rb` and `/raidbingo` both open the card; `/rb` again hides it

### Deck Selection and Cards
- [ ] The dropdown lists Raid Generic, Black Temple, Mount Hyjal, Serpentshrine Cavern, Tempest Keep, and Zul'Aman
- [ ] Each dropdown choice shows a new 5×5 card
- [ ] `/rb za` selects Zul'Aman and shows Zul'Aman squares
- [ ] The Boxes dropdown selects 80%, 100%, and 120%; the Text dropdown selects 5–10, 12, 14, 16, and 18 pt, and long labels still fit
- [ ] The Window dropdown selects 25%, 50%, 75%, 100%, 125%, and 150%; scale stays within the screen and persists after reload
- [ ] Changing box size keeps the grid centered, reduces unused frame space, and does not clip selectors, checkbox, or card
- [ ] The minimap button toggles the card without Lua errors
- [ ] The saved **Automark based on events** checkbox persists; `/rb automark` toggles it too
- [ ] With automark enabled during a raid, defeating a boss or killing a named mob on the current card marks the matching square
- [ ] Taking a listed spell/mechanic hit marks its matching square; an unrelated hit does not mark it
- [ ] Saying a quoted phrase from a card square in raid/party chat marks that square
- [ ] `/rb generic` selects the raid-neutral pool; its squares do not name raids or bosses
- [ ] Raid-specific cards contain a random 2–8 squares for that raid and generic moments in the remaining spaces
- [ ] The center says FREE and appears marked green
- [ ] No card contains duplicate squares; shorter raid pools can include generic squares
- [ ] `/rb new` creates another card; `/rb reset` clears marks

### Marking and Bingo
- [ ] Long square labels wrap and scale down while keeping visible padding inside their cells
- [ ] The 5×5 grid is centered in a compact window with modest margins and labels remain fully visible at each window scale
- [ ] Clicking a square changes only its red backdrop to pastel green; clicking it again restores red
- [ ] The separate frame remains visible and the text color stays the same in both marked and unmarked states
- [ ] The Automark based on event checkbox and label are centered together above the card
- [ ] The center cell matches the other cell dimensions, stays green, and centers `FREE`
- [ ] Marks remain after reloading the UI or relogging with the same card
- [ ] Completing a horizontal or vertical line yells `BINGO!!!!!!!!!` with one randomly selected Monkey Island-themed quip
- [ ] The addon performs `/laugh` after the yell
- [ ] A card yells only once; a new card can announce again

## Release Artifacts and Installation Steps

### Release Artifacts
- GitHub prerelease ZIP archive containing:
  - `raid_bingo_addon` folder at root
  - `raid_bingo_addon.toc` file with correct interface version (20506)
  - All required Lua modules
  - No extraneous files or directories

### Installation Steps
1. Download the latest GitHub prerelease
2. Extract `raid_bingo_addon` folder directly into the WoW client's `Interface/AddOns` directory
3. Enable the addon in the AddOns list
4. Use `/rb` or `/raidbingo` to show/hide the card

### Versioning and Update Checking
- Version numbers follow semantic versioning with pre-release tags (e.g., v0.1.0-rc.1)
- Updates are checked by downloading new releases from GitHub
- No automatic update checking is implemented in the addon itself

## Release Gates

A candidate release should have:
- A focused PR with clear changes
- Passing automated/static checks
- Verified archive containing expected addon folder and TOC
- Signed release notes
- Clear list of owner-only checks
- Do not claim in-game compatibility until owner reports it

## Development Process

1. Keep changes small and focused
2. Use isolated task branches/worktrees
3. Open focused PRs for each change
4. Run static checks before committing
5. Publish versioned GitHub prereleases for owner testing
6. Validate source/catalog rules where tooling is available
7. Run [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md) in the game client before claiming runtime compatibility

## Validation Process

- All automated checks must pass before a release candidate
- Owner validation using the smoke test checklist is required for stable releases
- Release candidates are tagged with `v0.1.0-rc.N` format
- Stable releases are promoted only after owner confirmation of in-game functionality