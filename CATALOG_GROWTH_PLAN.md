# Fantastiq Bingo TBC catalog growth plan

## Verified catalog status (2026-11-05)

The current `lua validate_catalog.lua` run reports 535 catalog entries and 506
globally unique prompt texts. The raid-generic pool has 208 entries, exceeding
the original target of 100 generic prompts and the overall goal of 500 distinct
prompts. Pool counts below come from the validator. It does not report
normalized distinct counts per pool, so those values are not inferred here.

| Pool | Entries | Distinct text |
| --- | ---: | ---: |
| Black Temple | 52 | Not reported |
| Mount Hyjal | 30 | Not reported |
| Serpentshrine Cavern | 50 | Not reported |
| Tempest Keep | 53 | Not reported |
| Zul'Aman | 50 | Not reported |
| Raid generic | 208 | Not reported |
| Class and role | 40 | Not reported |
| Mechanics | 32 | Not reported |
| Funny | 20 | Not reported |
| **Total** | **535** | **506 globally** |

The current validator checks unique IDs across pools, unique text within each
pool, duplicate raid-specific wording against the generic pool, generic ID
format, named raid/boss terms in generic prompts, and the 50-character limit.
Avoid claiming stronger global uniqueness than the measured total supports.
Subjective moments remain manual.

## Historical work queue

The original plan below tracked issues #38–#44. The measured catalog has
already passed the original 500-distinct-text target. This is historical
context; review any still-open historical issues before closing them, and do
not add filler prompts just to meet the old target.

| Issue | Batch | Original target | Depends on |
| --- | --- | ---: | --- |
| #39 | Raid-generic moments | 50 | #38 |
| #40 | Black Temple and Mount Hyjal moments | 50 | #39 |
| #41 | SSC and Tempest Keep moments | 50 | #40 |
| #42 | Zul'Aman and raid-neutral social moments | 50 | #41 |
| #43 | Class, role, and observable-mechanic moments | 50 | #42 |
| #44 | Final distinct-content top-up and recount | 9 | #43 |

These were target additions, not permission to pad the catalog. Every candidate
must be concise, distinct, plausible for its pool, and not claim an event the
addon cannot observe. No batch changes the UI, saved-variable schema, or event
automation rules.

## Counting and validation

Run `lua validate_catalog.lua` from the addon directory. It checks catalog IDs,
text uniqueness within each pool, generic-versus-raid text collisions, generic
pool requirements, text length, and named encounter terms. The validator does
not currently perform Unicode NFKC normalization or report per-playable-deck
unique counts; treat those as future validator improvements if they remain
useful after reviewing issues #38–#44.

Live client smoke testing remains tracked separately in [#23](https://github.com/fantastiqlabs/fantastiq-bingo-tbc/issues/23).
