# Issue 1: Raid Bingo MVP decisions

## Decision

The addon is a standalone TBC Classic Anniversary tool. Each player has a private, locally saved randomized 5×5 card with an automatic free center. Players can mark or unmark cells themselves. A completed horizontal or vertical line triggers one local `/yell BINGO!!!!!!!!!` with a randomized Monkey Island quip, followed by `/laugh`.

Raid-specific cards contain a random 2–8 squares from the selected raid plus generic moments. The Raid Generic deck contains raid-neutral squares only. Square marks are self-reported; this is not attendance, loot, or achievement verification.

## Out of scope for the MVP

- Shared cards, addon messaging, leader control, or cross-player marks.
- Portal integration, authentication, statistics, or rewards.
- Reliable verification of subjective moments.

The shipped candidate and owner smoke-test gate are summarized in [README.md](README.md) and [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md).
