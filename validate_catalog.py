#!/usr/bin/env python3
"""Catalog validator for Raid Bingo Addon.
Checks: unique IDs, generic-pool count ≥100, duplicate text, forbidden raid/boss terms.
"""

import re
import sys


def validate_catalog(catalog_path):
    """Validate the raid_bingo_catalog.lua file."""
    with open(catalog_path, "r", encoding="utf-8") as f:
        content = f.read()

    errors = []
    warnings = []

    # Extract raid_generic section using a more robust regex
    # Look for the raid_generic = { ... } block
    raid_generic_match = re.search(
        r"raid_generic\s*=\s*\{(.*?)\n\s*\},?\s*\n",
        content,
        re.DOTALL
    )

    if not raid_generic_match:
        print("ERROR: Could not find raid_generic section")
        return False

    raid_generic_section = raid_generic_match.group(1)

    # Extract all entries with id and text
    entries = []
    # Match patterns like: { id = "generic_001", text = "some text", ... }
    entry_pattern = re.compile(
        r'\{\s*id\s*=\s*["\']([^"\']+)["\']\s*,\s*text\s*=\s*["\']([^"\']+)["\']',
        re.DOTALL
    )

    for match in entry_pattern.finditer(raid_generic_section):
        entry_id = match.group(1)
        text = match.group(2)
        entries.append({"id": entry_id, "text": text})

    # Check count
    count = len(entries)
    if count < 100:
        errors.append(f"raid_generic pool has {count} entries, needs at least 100")
    else:
        print(f"✓ raid_generic pool has {count} entries (≥100)")

    # Check for duplicate IDs
    seen_ids = {}
    for entry in entries:
        if entry["id"] in seen_ids:
            errors.append(f"Duplicate ID found: {entry['id']}")
        seen_ids[entry["id"]] = True
    if seen_ids:
        print("✓ All IDs are unique")

    # Check for duplicate text
    seen_text = {}
    for entry in entries:
        if entry["text"] in seen_text:
            errors.append(f"Duplicate text found: {entry['text']}")
        seen_text[entry["text"]] = True
    if seen_text:
        print("✓ No duplicate text entries")

    # Check for forbidden terms (case-insensitive)
    forbidden_terms = [
        "black temple", "illidan", "gurtogg", "shahraz", "najentus", "supremus",
        "teron", "akama", "mount hyjal", "rage winterchill", "anetheron", "kazrogal",
        "azgalor", "archimonde", "serpentshrine", "fathom-lord", "karathress", "vashj",
        "morogrim", "tidewalker", "hydross", "tempest keep", "kael'thas", "kael",
        "void reaver", "skarloc", "nexus-stalker", "illidari", "zul'am", "nalorakk",
        "akil'zon", "jan'alai", "halazzi", "malacrass", "zul'jin", "blackrock", "onion",
        "pyre", "temple", "hyjal", "ssc", "tk", "bt", "za"
    ]

    found_forbidden = {}
    for entry in entries:
        text_lower = entry["text"].lower()
        for term in forbidden_terms:
            if term in text_lower:
                warnings.append(
                    f"Entry '{entry['id']}' may contain forbidden term '{term}': {entry['text']}"
                )
                if term not in found_forbidden:
                    found_forbidden[term] = True

    if found_forbidden:
        print("WARNING: Found entries with potential forbidden terms:")
        for term in found_forbidden:
            print(f"  - {term}")
    else:
        print("✓ No forbidden raid/boss terms found")

    # Print results
    print("\n=== VALIDATION RESULTS ===")
    if errors:
        print(f"ERRORS ({len(errors)}):")
        for err in errors:
            print(f"  ✗ {err}")
    else:
        print("No errors found!")

    if warnings:
        print(f"WARNINGS ({len(warnings)}):")
        for warn in warnings:
            print(f"  ! {warn}")

    return len(errors) == 0


if __name__ == "__main__":
    catalog_path = sys.argv[1] if len(sys.argv) > 1 else "raid_bingo_catalog.lua"
    success = validate_catalog(catalog_path)

    if success:
        print("\n✓ Catalog validation PASSED")
        sys.exit(0)
    else:
        print("\n✗ Catalog validation FAILED")
        sys.exit(1)
