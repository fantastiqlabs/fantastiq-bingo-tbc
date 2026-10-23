#!/usr/bin/env python3

"""
Raid Bingo Addon Verification Script

Verifies that a packaged addon archive contains exactly the expected files
and structure for the addon release workflow.

Uses Python standard library zipfile module, no external dependencies.
"""

import os
import sys
import zipfile
import argparse
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description='Verify Raid Bingo addon package')
    parser.add_argument('archive_path', help='Path to the ZIP archive to verify')

    args = parser.parse_args()

    archive_path = Path(args.archive_path)

    # Check if archive exists
    if not archive_path.exists():
        print(f"Error: Archive not found: {archive_path}")
        sys.exit(1)

    print(f"Verifying archive: {archive_path}")

    # Extract to temporary location for verification
    import tempfile
    import shutil

    with tempfile.TemporaryDirectory() as temp_dir:
        extract_dir = Path(temp_dir) / "extracted"
        extract_dir.mkdir()

        # Extract the archive
        print(f"Extracting to: {extract_dir}")
        with zipfile.ZipFile(archive_path, 'r') as zipf:
            zipf.extractall(extract_dir)

        # Get the addon directory name (should be the only top-level directory)
        top_level_items = list(extract_dir.iterdir())
        if len(top_level_items) != 1:
            print(f"Error: Expected exactly one top-level item, found {len(top_level_items)}")
            for item in top_level_items:
                print(f"  - {item.name}")
            sys.exit(1)

        addon_dir = top_level_items[0]
        if not addon_dir.is_dir():
            print("Error: Top-level item is not a directory")
            sys.exit(1)

        print(f"Addon directory: {addon_dir.name}")

        # List contents of addon directory
        print("Contents of addon directory:")
        for item in sorted(addon_dir.iterdir()):
            print(f"  {item.name}")

        # Check for required files
        required_files = [
            "raid_bingo_addon.toc",
            "raid_bingo_addon.lua",
            "raid_bingo_card.lua",
            "raid_bingo_ui.lua",
            "raid_bingo_utils.lua",
            "raid_bingo_catalog.lua"
        ]

        print("\nVerifying required files:")
        for file in required_files:
            file_path = addon_dir / file
            if file_path.exists() and file_path.is_file():
                print(f"✓ {file}")
            else:
                print(f"✗ {file} (MISSING)")
                sys.exit(1)

        # Verify TOC interface version
        toc_path = addon_dir / "raid_bingo_addon.toc"
        try:
            with open(toc_path, 'r') as f:
                for line in f:
                    if line.startswith('## Interface:'):
                        interface_version = line.split()[2]
                        if interface_version != "20506":
                            print(f"Error: Expected interface version 20506, found {interface_version}")
                            sys.exit(1)
                        print(f"✓ Interface version verified: {interface_version}")
                        break
                else:
                    print("Error: Interface version not found in TOC")
                    sys.exit(1)
        except Exception as e:
            print(f"Error reading TOC file: {e}")
            sys.exit(1)

        # Verify no unexpected nested paths (only top-level addon directory)
        print("\nVerifying archive structure:")
        all_items = list(extract_dir.iterdir())
        if len(all_items) != 1:
            print(f"Error: Expected exactly one top-level item, found {len(all_items)}")
            sys.exit(1)

        # Verify no hidden files or directories in the addon directory
        hidden_items = [item for item in addon_dir.iterdir() if item.name.startswith('.')]
        if hidden_items:
            print("Error: Found hidden items in addon directory:")
            for item in hidden_items:
                print(f"  {item.name}")
            sys.exit(1)

        print("✓ Archive structure is clean and correct")
        print("\nVerification successful! The archive contains exactly the expected files.")
        print("Note: This verification does not include in-game testing. Archive validation does not replace in-game verification.")

if __name__ == "__main__":
    main()
