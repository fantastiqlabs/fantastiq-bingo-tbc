# Fantastiq Bingo TBC candidate status

## Current state

The current branch contains a standalone TBC Anniversary addon candidate with a 5×5 board, a raid dropdown, randomized pools, clickable private marks, a free center square. Selectable pools include Black Temple, Mount Hyjal, SSC, Tempest Keep, Zul'Aman, and raid-generic content. Short raid pools are filled with unique generic squares so the card has 24 non-center cells.

The TOC targets interface `20506`. Marks and card layout are local and self-reported. No encounter tracking, attendance, or achievements are verified. No in-game test has been performed; the candidate still needs owner testing in the Anniversary client.

## Release gates

- Source-level pool checks confirm 30 unique Zul'Aman entries and 30 unique generic entries, with no raid/boss terms in generic square text.
- Build and verify a versioned ZIP from the exact candidate commit.
- Confirm the pre-release notes identify it as unverified and include the smoke checklist.
- Owner runs [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md) in-game and reports results.

## Limits

- A Lua interpreter/parser is not installed in the current roost environment, so Lua syntax has not been independently compiled here.
- The larger catalog's total unique-square count has not been audited; older “500+” claims are not verified.
- Encounter-specific square accuracy and TBC client behavior need the in-game smoke test.
