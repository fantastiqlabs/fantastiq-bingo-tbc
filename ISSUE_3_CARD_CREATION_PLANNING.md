# Issue 3: Card creation and addon-to-addon sharing

## Card Creator/Selection/Distribution Approach:
Based on the MVP requirements, I'll implement a **fixed card approach** where:
1. Officers define the bingo card content before raid
2. The card is distributed as part of the addon package
3. All players receive the same card (shared set)

### Rationale for Fixed Card:
- Simpler implementation
- Consistent experience across all players
- No need for complex distribution mechanisms
- Matches reference behavior described in issue 1

## Offline/Late/Reconnect Behavior:

### Offline/No Addon:
- Players without addon simply participate normally (no bingo tracking)
- No impact on raid participation or progression

### Late Join/Reload:
- New players joining mid-raid get the same card as others
- Reloads preserve player's marking state
- Card content is persistent across sessions

## Progress Locality/Privacy:

### Privacy Model:
- Each player's marks are private to that player only
- No cross-player visibility of markings
- Only local completion tracking per player

### Data Storage:
- SavedVariables for each player's own marking data
- Shared card definition stored in addon files
- No external communication required

## Message Size/Channel/Trust Concerns:

### Communication Approach:
Since we're using a fixed card approach, minimal messaging is needed.
However, if we implement any sharing features later, we'll use:
1. **Standard Addon Messaging** - Blizzard's C_ChatInfo.SendAddonMessage
2. **Private Channels** - For player-to-player communication
3. **Guild/Group Channels** - For officer coordination

### Trust Model:
- No automatic verification of marks (as per MVP)
- Players self-report their progress
- No external validation or authentication required

## Flow Diagram:

```
[Officer] -> [Define Card Content] -> [Package into Addon]
                              |
                              v
[Players Download/Install Addon] -> [Receive Shared Card]
                              |
                              v
[During Raid] -> [Mark Squares Locally] -> [Track Lines Locally]
                              |
                              v
[End of Raid] -> [Optional Sharing] -> [No Automatic Verification]
```

## Implementation Approach:
1. Start with fixed card content in addon files
2. Implement basic marking functionality
3. Add local line completion tracking
4. Ensure persistence across sessions

## Dependencies:
- Issue 1 (MVP definition) - for understanding requirements
- Issue 2 (client target) - for API compatibility
