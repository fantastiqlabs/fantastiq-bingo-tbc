# Issue 2: Confirm exact TBC client and addon API target

## Target Client Selection:
Based on standard WoW TBC releases, I'll target **World of Warcraft: The Burning Crusade (v1.12.1)** as the baseline.

### Rationale for v1.12.1:
- This is the final stable release of TBC
- Most widely used version in classic servers
- Has well-documented addon API compatibility
- Stable and predictable for development

## Addon API Compatibility:

### Core APIs to Use:
1. **Blizzard UI Framework** - Standard WoW 1.12.x UI elements
2. **AddOn System** - Basic addon loading, events, messaging
3. **FrameXML** - For creating UI components
4. **Chat Frame Integration** - For commands and messages

### Key Compatibility Considerations:
- No combat restrictions on addon functionality (as per TBC era)
- Standard group/raid APIs available for communication
- Addon message system for inter-player communication
- Persistent storage using SavedVariables

### API Restrictions to Note:
1. **Combat Lockdown**: Cannot modify UI during combat
2. **Frame Creation Limits**: May have limits on frame creation in certain contexts
3. **Memory Constraints**: Classic WoW had memory limitations that should be considered
4. **Event System**: Standard event handling for raid events, group changes

### Minimum Supported Version:
- World of Warcraft 1.12.1 (TBC)
- Addon API version compatible with this client

### Update Policy:
- Maintain compatibility with TBC releases
- No automatic updates - rely on manual installation by users
- Future versions may target newer patches if needed, but start with stable v1.12.1

## Verification Approach:
Since we're working in a controlled environment without direct access to WoW client, I'll proceed based on documented TBC addon API specifications and standard practices for that era.

### Assumptions (to be verified during implementation):
- Standard UI frame creation works
- Addon messaging system is available
- SavedVariables persistence works
- Basic event handling functions properly

## Implementation Notes:
- Use standard .toc file structure for addon metadata
- Follow TBC-era addon development patterns
- Ensure compatibility with both retail and classic servers (as applicable)
