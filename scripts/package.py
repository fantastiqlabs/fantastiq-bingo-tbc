#!/usr/bin/env python3

"""
Raid Bingo Addon Packaging Script

Creates a versioned ZIP archive of the addon files for the addon release workflow.
This script does not perform in-game verification - that will be done after issue #9 integration.

Uses Python standard library zipfile module, no external dependencies.
"""

import os
import sys
import zipfile
import argparse
from pathlib import Path

def get_version_from_toc():
    """Extract version from addon TOC file."""
    try:
        with open('raid_bingo_addon.toc', 'r') as f:
            for line in f:
                if line.startswith('## Version:'):
                    return line.split()[2]
    except FileNotFoundError:
        print("Error: raid_bingo_addon.toc not found")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading TOC file: {e}")
        sys.exit(1)

    print("Error: Could not determine version from TOC file")
    sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='Package Raid Bingo addon')
    parser.add_argument('-o', '--output', default='/tmp', help='Output directory (default: /tmp)')
    parser.add_argument('-n', '--name', default='raid_bingo_addon', help='Package name (default: raid_bingo_addon)')

    args = parser.parse_args()

    # Get version from TOC
    version = get_version_from_toc()
    print(f"Using version: {version}")

    # Create output directory if it doesn't exist
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Define files to include
    addon_files = [
        'raid_bingo_addon.toc',
        'raid_bingo_addon.lua',
        'raid_bingo_card.lua',
        'raid_bingo_ui.lua',
        'raid_bingo_utils.lua',
        'raid_bingo_catalog.lua'
    ]

    # Verify all files exist
    for file in addon_files:
        if not os.path.exists(file):
            print(f"Error: Required file not found: {file}")
            sys.exit(1)

    # Create package name with version
    archive_name = f"{args.name}_{version}.zip"
    archive_path = output_dir / archive_name

    # Create the ZIP archive
    print(f"Creating archive: {archive_path}")

    with zipfile.ZipFile(archive_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add files to the archive with the addon directory structure
        for file in addon_files:
            # Add file to archive with path inside the addon directory
            zipf.write(file, arcname=f"{args.name}/{file}")

    print(f"Package created successfully: {archive_path}")
    print("Note: This package has not been verified in-game. Archive validation does not replace in-game verification.")

if __name__ == "__main__":
    main()
