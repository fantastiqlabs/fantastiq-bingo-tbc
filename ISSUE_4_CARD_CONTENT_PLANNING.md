# Issue 4: Card content, rules, lifecycle

## Card Content Approach:
Based on the MVP requirements and reference behavior, I'll implement:

### Fixed Card Content:
- Predefined set of 25 bingo squares (5x5 grid)
- Each square contains a specific raid objective or challenge
- Center square is always "Free Space"
- Content curated for TBC raid scenarios

### Sample Bingo Square Content:
1. Defeat a boss in the raid
2. Get a specific achievement during raid
3. Complete a specific encounter without wipes
4. Kill a certain number of mobs
5. Use a specific ability or spell
6. Reach a certain amount of damage/healing
7. Complete a specific mechanic
8. Obtain a rare item drop
9. Achieve a specific stat threshold

### Card Structure:
```
[Square 1] [Square 2] [Square 3] [Square 4] [Square 5]
[Square 6] [Square 7] [Square 8] [Square 9] [Square 10]
[Square 11] [Square 12] [FREE SPACE] [Square 14] [Square 15]
[Square 16] [Square 17] [Square 18] [Square 19] [Square 20]
[Square 21] [Square 22] [Square 23] [Square 24] [Square 25]
```

## Rules Definition:

### Line Completion:
- Horizontal lines (5 squares in a row)
- Vertical lines (5 squares in a column)
- Diagonal lines (from corner to corner)

### Center Square:
- Always marked as complete
- Cannot be unmarked by players
- Serves as the "Free Space" for bingo

### Marking Rules:
1. Players can mark their own squares only
2. Marks are private - other players cannot see them
3. No automatic verification of completion
4. Players self-report their progress

## Lifecycle Management:

### Card Creation:
- Card content defined in addon files during development
- Content curated for TBC raid scenarios and challenges

### During Raid:
- Players mark squares as they complete objectives
- Line detection happens locally per player
- No external communication required

### End of Raid:
- No automatic scoring or rewards
- Players can share completed lines if desired
- Data persists between sessions

## Authoring/Validation:

### Content Creation:
1. Curated by officers or addon maintainers
2. Based on TBC raid mechanics and challenges
3. Tested for balance and difficulty

### Validation Process:
- Review of content against TBC raid scenarios
- Balance check to ensure reasonable completion targets
- No automated validation needed - manual review sufficient

## Localization Considerations:

### Language Support:
- English base content (standard for WoW addons)
- Future expansion possible with localization files if time permits

## Edge Scenarios:

1. **Multiple Lines**: Player can complete multiple lines in one session
2. **Reversal of Marks**: No mechanism to unmark squares once marked
3. **Incomplete Cards**: Players may not complete all objectives
4. **Late Joiners**: New players get same card content as others

## Implementation Approach:
1. Define fixed card content in addon files
2. Implement marking system with private storage
3. Add line detection logic for horizontal, vertical, diagonal lines
4. Ensure persistence of player data across sessions

## Dependencies:
- Issue 1 (MVP definition) - for understanding requirements
- Issue 3 (card creation/sharing) - for implementation approach
