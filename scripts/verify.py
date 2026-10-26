#!/usr/bin/env python3
"""Verify Raid Bingo ZIP structure, paths, CRCs, and TOC metadata."""

import argparse
import re
import stat
import sys
import zipfile
from pathlib import Path, PurePosixPath

ADDON_DIRECTORY = "raid_bingo_addon"
REQUIRED_FILES = frozenset({
    "raid_bingo_addon.toc",
    "raid_bingo_addon.lua",
    "raid_bingo_card.lua",
    "raid_bingo_ui.lua",
    "raid_bingo_utils.lua",
    "raid_bingo_catalog.lua",
})
EXPECTED_INTERFACE = "20506"
VERSION_PATTERN = re.compile(r"^## Version:\s*(\S+)\s*$", re.MULTILINE)


class VerificationError(ValueError):
    """The archive does not satisfy the installable addon contract."""


def verify_archive(archive_path):
    """Validate the archive without extracting untrusted paths to disk."""
    archive_path = Path(archive_path)
    if not archive_path.is_file():
        raise VerificationError(f"Archive not found: {archive_path}")
    try:
        with zipfile.ZipFile(archive_path, "r") as archive:
            infos = archive.infolist()
            names = [item.filename for item in infos]
            if len(names) != len(set(names)):
                raise VerificationError("Duplicate archive paths are not allowed")

            expected_names = {f"{ADDON_DIRECTORY}/{name}" for name in REQUIRED_FILES}
            for info in infos:
                name = info.filename
                if not name or "\\" in name or "\x00" in name:
                    raise VerificationError(f"Unsafe archive path: {name!r}")
                path = PurePosixPath(name)
                if path.is_absolute() or any(part in {"", ".", ".."} for part in name.split("/")):
                    raise VerificationError(f"Unsafe archive path: {name!r}")
                if len(path.parts) != 2 or path.parts[0] != ADDON_DIRECTORY:
                    raise VerificationError(f"Unexpected addon path: {name!r}")
                if info.is_dir():
                    raise VerificationError(f"Unexpected directory entry: {name!r}")
                mode = (info.external_attr >> 16) & 0xFFFF
                file_type = stat.S_IFMT(mode)
                if file_type and file_type != stat.S_IFREG:
                    raise VerificationError(f"Non-regular archive entry: {name!r}")

            actual_names = set(names)
            if actual_names != expected_names:
                missing = sorted(expected_names - actual_names)
                unexpected = sorted(actual_names - expected_names)
                raise VerificationError(f"Archive file set mismatch; missing={missing}, unexpected={unexpected}")

            bad_member = archive.testzip()
            if bad_member is not None:
                raise VerificationError(f"CRC check failed for {bad_member}")

            toc_name = f"{ADDON_DIRECTORY}/raid_bingo_addon.toc"
            try:
                toc_text = archive.read(toc_name).decode("utf-8")
            except (UnicodeDecodeError, KeyError) as error:
                raise VerificationError("TOC is missing or is not valid UTF-8") from error
            interfaces = re.findall(r"^## Interface:\s*(\S+)\s*$", toc_text, re.MULTILINE)
            versions = VERSION_PATTERN.findall(toc_text)
            if interfaces != [EXPECTED_INTERFACE]:
                raise VerificationError(f"Expected exactly one interface version {EXPECTED_INTERFACE}; found {interfaces}")
            if len(versions) != 1:
                raise VerificationError(f"Expected exactly one TOC version; found {versions}")
            version = versions[0]
            if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._+-]*", version):
                raise VerificationError(f"Unsafe TOC version: {version!r}")
            if not archive_path.stem.endswith(f"_{version}"):
                raise VerificationError(f"Archive filename version does not match TOC version {version}")
            return version
    except zipfile.BadZipFile as error:
        raise VerificationError(f"Invalid ZIP archive: {error}") from error


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive_path", help="Path to the ZIP archive to verify")
    parser.add_argument("--strict", action="store_true", help="Accepted for compatibility; CRC is always checked")
    args = parser.parse_args()
    try:
        version = verify_archive(args.archive_path)
    except (OSError, VerificationError) as error:
        print(f"Verification failed: {error}", file=sys.stderr)
        return 1
    print(f"Verification successful: version {version}, interface {EXPECTED_INTERFACE}, exact file set, safe paths, CRC valid.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
