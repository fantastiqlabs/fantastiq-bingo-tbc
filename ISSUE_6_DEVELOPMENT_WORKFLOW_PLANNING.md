# Issue 6: Development, test, package, release workflow

## Repository Layout:

### Proposed Structure:
```
hellothereguild-raid-bingo-addon/
├── README.md
├── raid_bingo_addon.toc
├── raid_bingo_addon.lua
├── raid_bingo_card.lua
├── raid_bingo_ui.lua
├── raid_bingo_utils.lua
└── LICENSE
```

### File Descriptions:
- **raid_bingo_addon.toc**: Addon metadata and dependencies
- **raid_bingo_addon.lua**: Main addon logic and initialization
- **raid_bingo_card.lua**: Card content and management
- **raid_bingo_ui.lua**: User interface components
- **raid_bingo_utils.lua**: Utility functions for the addon

## TOC Metadata:

### Required Fields:
- **Title**: Raid Bingo Addon
- **Version**: 1.0.0 (initial)
- **Author**: HelloThereGuild
- **Interface**: 11201 (WoW TBC v1.12.1)
- **SavedVariables**: RaidBingoDB

## License Approach:
- MIT License - standard for WoW addons
- Clear attribution to the original project and contributors

## Static Checks and Testing:

### Code Quality:
- Lua syntax validation using standard linters
- No automated test suite (as specified in task brief)
- Manual verification during development

### In-client Checklist:
1. Addon loads without errors
2. UI displays correctly
3. Marking functionality works
4. Line detection functions properly
5. Data persistence works across sessions

## Versioning/Distribution:

### Version Strategy:
- Semantic versioning (major.minor.patch)
- Initial release: 1.0.0
- Future updates based on feature additions or bug fixes

### Distribution Approach:
- GitHub releases for distribution
- No automatic update mechanism
- Manual installation by users required

## Package Structure:
```
raid_bingo_addon/
├── raid_bingo_addon.toc
├── raid_bingo_addon.lua
├── raid_bingo_card.lua
├── raid_bingo_ui.lua
└── raid_bingo_utils.lua
```

## Installation Instructions:
1. Download the addon files
2. Extract to World of Warcraft/Interface/AddOns/
3. Restart WoW client or reload UI
4. Use /bingo command to open interface

## Implementation Approach:

### Development Phases:
1. **Core Structure**: TOC file, basic addon loading
2. **Card System**: Card definition and management
3. **UI Components**: Interface for marking squares
4. **Logic Layer**: Marking, line detection, persistence
5. **Testing**: Manual verification in client environment

### Testing Approach:
- Manual testing within WoW client (as specified)
- No automated test suite
- Verification of core functionality only

## Dependencies:
- Issue 2 (client target) - for API compatibility requirements
- Issue 3 (card creation/sharing) - for implementation approach
