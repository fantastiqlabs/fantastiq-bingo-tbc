"""Installable archive contracts for supported Raid Bingo clients."""

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

TARGETS = {
    "tbc": {
        "source_directory": ".",
        "addon_directory": ADDON_DIRECTORY,
        "toc": "raid_bingo_addon.toc",
        "interface": EXPECTED_INTERFACE,
        "files": REQUIRED_FILES,
    },
    "forever": {
        "source_directory": "wow_forever",
        "addon_directory": "fantastiq_bingo_forever",
        "toc": "fantastiq_bingo_forever.toc",
        "interface": "16001",
        "files": (
            "fantastiq_bingo_forever.toc",
            "fantastiq_bingo_forever.lua",
            "fantastiq_bingo_forever_catalog.lua",
            "fantastiq_bingo_forever_boards.lua",
        ),
    },
}


def parse_toc_metadata(contents, expected_interface=EXPECTED_INTERFACE):
    """Return the verified interface and version declared by TOC text."""
    interfaces = _INTERFACE_FIELD.findall(contents)
    versions = _VERSION_FIELD.findall(contents)
    if interfaces != [expected_interface]:
        raise ValueError(f"Expected exactly one interface version {expected_interface}; found {interfaces}")
    if len(versions) != 1:
        raise ValueError(f"Expected exactly one TOC version; found {versions}")
    version = versions[0]
    if not _SAFE_VERSION.fullmatch(version):
        raise ValueError(f"Unsafe TOC version: {version!r}")
    return interfaces[0], version
