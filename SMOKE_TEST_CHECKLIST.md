# Raid Bingo Addon Smoke Test Checklist

## Pre-Installation Verification
- [ ] World of Warcraft: The Burning Crusade Anniversary Edition (Interface 20506) is installed
- [ ] Addon folder structure is correct
- [ ] raid_bingo_addon.toc file specifies Interface: 11201

## Installation Verification
- [ ] Addon loads without errors in World of Warcraft
- [ ] Addon appears in the addon list
- [ ] No Lua errors appear during startup

## Basic Functionality Test
- [ ] `/raidbingo` or `/rb` command opens the interface
- [ ] Main bingo card displays correctly
- [ ] Free center square is properly marked
- [ ] Card shows 25 squares (5x5 grid)
- [ ] All raid-specific decks are available in the selector

## Raid-Specific Deck Testing
- [ ] Black Temple deck loads and displays correctly
- [ ] Mount Hyjal deck loads and displays correctly
- [ ] Serpentshrine Cavern (SSC) deck loads and displays correctly
- [ ] Tempest Keep (Kael'thas) deck loads and displays correctly
- [ ] Zul'Aman deck loads and displays correctly
- [ ] Raid-Generic Pool deck loads and displays correctly

## Card Generation Test
- [ ] Random card generation works without duplicates
- [ ] Free center square is properly marked
- [ ] No duplicate squares in generated cards
- [ ] All squares are from the selected raid pool

## Interface Functionality
- [ ] Clicking squares marks them as complete
- [ ] Right-clicking squares unmarks them
- [ ] Card reset functionality works
- [ ] Deck selection changes cards correctly
- [ ] Interface is responsive and user-friendly

## Post-Test Verification
- [ ] All data persists between sessions
- [ ] No performance impact on gameplay
- [ ] Addon doesn't interfere with other addons
- [ ] All raid-specific mechanics are properly represented

## Notes
- This checklist should be run in a TBC Anniversary Edition client
- In-game compatibility verification is pending owner testing
- Any Lua errors or unexpected behavior should be documented