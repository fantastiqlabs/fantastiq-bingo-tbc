#!/usr/bin/env python3
"""Verify Raid Bingo ZIP structure, paths, CRCs, and TOC metadata."""

import argparse
import stat
import sys
import zipfile
from pathlib import Path, PurePosixPath

from package_contract import (
    ADDON_DIRECTORY,
    EXPECTED_INTERFACE,
    REQUIRED_FILES,
    TARGETS,
    parse_toc_metadata,
)


class VerificationError(ValueError):
    """The archive does not satisfy the installable addon contract."""


def verify_archive(archive_path, target="tbc"):
    """Validate the archive without extracting untrusted paths to disk."""
    if target not in TARGETS:
        raise VerificationError(f"Unknown package target: {target}")
    contract = TARGETS[target]
    addon_directory = contract["addon_directory"]
    files = contract["files"]
    archive_path = Path(archive_path)
    if not archive_path.is_file():
        raise VerificationError(f"Archive not found: {archive_path}")
    try:
        with zipfile.ZipFile(archive_path, "r") as archive:
            infos = archive.infolist()
            names = [item.filename for item in infos]
            if len(names) != len(set(names)):
                raise VerificationError("Duplicate archive paths are not allowed")

            expected_names = {f"{addon_directory}/{name}" for name in files}
            for info in infos:
                name = info.filename
                if not name or "\\" in name or "\x00" in name:
                    raise VerificationError(f"Unsafe archive path: {name!r}")
                path = PurePosixPath(name)
                if path.is_absolute() or any(part in {"", ".", ".."} for part in name.split("/")):
                    raise VerificationError(f"Unsafe archive path: {name!r}")
                if len(path.parts) != 2 or path.parts[0] != addon_directory:
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

            toc_name = f"{addon_directory}/{contract['toc']}"
            try:
                toc_text = archive.read(toc_name).decode("utf-8")
            except (UnicodeDecodeError, KeyError) as error:
                raise VerificationError("TOC is missing or is not valid UTF-8") from error
            try:
                _, version = parse_toc_metadata(toc_text, contract["interface"])
            except ValueError as error:
                raise VerificationError(str(error)) from error
            expected_filename = f"{addon_directory}_{version}.zip"
            if archive_path.name != expected_filename:
                raise VerificationError(
                    f"Expected archive filename {expected_filename!r}, found {archive_path.name!r}"
                )
            return version
    except zipfile.BadZipFile as error:
        raise VerificationError(f"Invalid ZIP archive: {error}") from error


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive_path", help="Path to the ZIP archive to verify")
    parser.add_argument("--target", choices=TARGETS, default="tbc", help="Client package (default: tbc)")
    parser.add_argument("--strict", action="store_true", help="Accepted for compatibility; CRC is always checked")
    args = parser.parse_args()
    try:
        version = verify_archive(args.archive_path, args.target)
    except (OSError, VerificationError) as error:
        print(f"Verification failed: {error}", file=sys.stderr)
        return 1
    interface = TARGETS[args.target]["interface"]
    print(f"Verification successful: version {version}, interface {interface}, exact file set, safe paths, CRC valid.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
