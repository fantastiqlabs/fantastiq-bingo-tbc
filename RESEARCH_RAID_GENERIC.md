# Raid-generic bingo deck status

A raid-generic pool is planned so cards can be used in different TBC raids without boss or raid names. Candidate squares include general encounter moments, class or role activities, consumable use, and broadly recognizable raid events.

This document is a design note, not evidence that the deck is implemented. Review `raid_bingo_catalog.lua` and deck selection in the addon before describing it as playable. Avoid measurable combat thresholds unless the game exposes a reliable way for players to observe them; marks remain self-reported.

## Follow-up

- Add a distinct generic pool with no raid-specific references.
- Ensure its selector appears in the UI and card generation uses only that pool when selected.
- Check for duplicates and make sure each pool has enough unique squares to fill a card.
- Validate the deck in the in-game smoke test.
