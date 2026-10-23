# Issue 1: Define the TBC raid-bingo addon MVP

## Current Understanding from Reference Behavior:
- Officer-started shared set of 25 squares (5x5 grid)
- Free center square
- Each player's marks private
- Marking only during event
- Completed line local to player
- Marks self-reported, no attendance or achievement verification
- No portal connectivity required for core experience

## MVP Definition:

### Core Features:
1. **Shared 25-square card (5x5 grid)** - Fixed set of bingo squares with predefined content
2. **Free center square** - Center square is always marked as complete
3. **Private marking** - Players can mark their own squares, but others cannot see marks
4. **Line completion tracking** - Local tracking of completed lines (horizontal, vertical, diagonal)
5. **Self-reported marks** - No automatic verification or attendance tracking

### Officer/Raider Flows:
1. **Card Preparation**:
   - Officers select/define the bingo card content before raid
   - Card is distributed to all raid members
2. **During Raid**:
   - Players mark their own squares as they complete objectives
   - Line completion is tracked locally per player
3. **Raid End**:
   - No automatic scoring or rewards
   - Players can share completed lines with others if desired

### Key Design Decisions:
1. **Shared Card**: Fixed card content, not randomized (for consistency)
2. **Private Marks**: Each player's marks are private to that player
3. **No Portal Integration**: Core experience works without portal connectivity
4. **Self-Reported Only**: No automatic verification of completion - players report their own progress

### Acceptance Criteria:
1. 5x5 grid with free center square
2. Private marking system (no cross-player visibility)
3. Line completion detection and display
4. Simple UI for marking squares
5. Persistence across raid sessions (if possible)

### Out-of-Scope Ideas:
1. Automatic attendance tracking or verification
2. Portal integration for syncing progress
3. Automated scoring/ranking systems
4. Cross-server communication features
5. Advanced statistics or analytics

## Implementation Approach:
- Start with a simple, functional addon that meets core requirements
- Focus on basic UI and marking functionality first
- Add more advanced features in later phases if time permits
