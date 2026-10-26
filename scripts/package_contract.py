"""Shared installable archive contract for the Raid Bingo packaging tools."""

import re

ADDON_DIRECTORY = "raid_bingo_addon"
EXPECTED_INTERFACE = "20506"
REQUIRED_FILES = (
    "raid_bingo_addon.toc",
    "raid_bingo_addon.lua",
    "raid_bingo_card.lua",
    "raid_bingo_ui.lua",
    "raid_bingo_utils.lua",
    "raid_bingo_catalog.lua",
)
_INTERFACE_FIELD = re.compile(r"^## Interface:\s*(\S+)\s*$", re.MULTILINE)
_VERSION_FIELD = re.compile(r"^## Version:\s*(\S+)\s*$", re.MULTILINE)
_SAFE_VERSION = re.compile(r"[A-Za-z0-9][A-Za-z0-9._+-]*")


def parse_toc_metadata(contents):
    """Return the verified interface and version declared by TOC text."""
    interfaces = _INTERFACE_FIELD.findall(contents)
    versions = _VERSION_FIELD.findall(contents)
    if interfaces != [EXPECTED_INTERFACE]:
        raise ValueError(f"Expected exactly one interface version {EXPECTED_INTERFACE}; found {interfaces}")
    if len(versions) != 1:
        raise ValueError(f"Expected exactly one TOC version; found {versions}")
    version = versions[0]
    if not _SAFE_VERSION.fullmatch(version):
        raise ValueError(f"Unsafe TOC version: {version!r}")
    return interfaces[0], version
