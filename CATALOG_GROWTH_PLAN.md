# Fantastiq Bingo TBC catalog growth plan

This plan treats the owner's goal of roughly 500 boxes as a direction. It counts
distinct prompt wording, not stable catalog IDs. A prompt can be repeated across
different pools today, so entry counts alone overstate variety.

## Baseline on `main` (2026-10-26)

Normalization is Unicode NFKC, case-folding, then collapsing whitespace. The
catalog has 300 entries and 241 distinct normalized texts overall: 59 extra
occurrences across 37 repeated-text groups.

| Pool | Entries | Distinct text |
| --- | ---: | ---: |
| Black Temple | 40 | 33 |
| Mount Hyjal | 20 | 14 |
| Serpentshrine Cavern | 20 | 15 |
| Tempest Keep | 20 | 15 |
| Zul'Aman | 30 | 30 |
| Raid generic | 110 | 110 |
| Class and role | 20 | 20 |
| Mechanics | 20 | 20 |
| Funny | 20 | 20 |
| **Total** | **300** | **241** |

The validation issue should remove repeated wording from every playable
combination: generic-only, and each raid pool with its generic filler. Preserve
stable IDs where practical; do not invent replacements merely to preserve entry
counts. A card still uses 24 unique prompts plus its free center, with 2–8
selected-raid prompts and generic filler. Keep each box at 50 characters or
fewer. Subjective moments remain manual.

## Work queue

The first implementation ticket is [#38](https://github.com/fantastiqlabs/fantastiq-bingo-tbc/issues/38).
It removes duplicate wording and strengthens the static catalog validator. Once
it is merged, the measured distinct baseline should remain 241 unless the audit
finds a counting defect.

The remaining gap is therefore 259 distinct prompts. It is split into six
dependent batches, each adding no more than 50 globally unique prompts:

| Issue | Batch | New prompts | Depends on |
| --- | --- | ---: | --- |
| #39 | Raid-generic moments | 50 | #38 |
| #40 | Black Temple and Mount Hyjal moments | 50 | #39 |
| #41 | SSC and Tempest Keep moments | 50 | #40 |
| #42 | Zul'Aman and raid-neutral social moments | 50 | #41 |
| #43 | Class, role, and observable-mechanic moments | 50 | #42 |
| #44 | Final distinct-content top-up and recount | 9 | #43 |

These are target additions, not permission to pad the catalog. Every candidate
must be concise, distinct after the same normalization, plausible for the named
pool, and not claim an event the addon cannot observe. If a batch cannot meet
its count without weak or inaccurate prompts, report the measured shortfall and
carry it into #44. No batch changes the UI, saved-variable schema, or event
automation rules.

## Counting and validation

Use the current catalog validator plus a focused uniqueness check that reports
entry counts, normalized unique counts, and duplicate IDs/text for each pool and
each playable raid-plus-generic combination. Verify the 2–8 raid-specific rule,
generic-only deck, 24 selectable cells, free center, and the 50-character text
limit. Do not claim the 500 target until the final count confirms at least 500
globally distinct prompt texts.

Live client smoke testing remains tracked separately in [#23](https://github.com/fantastiqlabs/fantastiq-bingo-tbc/issues/23).
