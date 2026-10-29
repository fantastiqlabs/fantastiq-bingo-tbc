#!/usr/bin/env python3
"""Create a deterministic, versioned Fantastiq Bingo TBC ZIP."""

import argparse
import hashlib
import sys
import zipfile
from pathlib import Path

from package_contract import ADDON_DIRECTORY, REQUIRED_FILES, parse_toc_metadata


def get_version_from_toc(toc_path=Path("raid_bingo_addon.toc")):
    """Return the single safe addon version declared in the TOC."""
    try:
        contents = toc_path.read_text(encoding="utf-8")
    except OSError as error:
        raise ValueError(f"Could not read {toc_path}: {error}") from error
    return parse_toc_metadata(contents)[1]


def package(output_dir, include_hashes=False):
    """Build an archive with fixed names, ordering, metadata, and timestamps."""
    version = get_version_from_toc()
    for file_name in REQUIRED_FILES:
        if not Path(file_name).is_file():
            raise ValueError(f"Required file not found: {file_name}")

    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    archive_path = output_dir / f"{ADDON_DIRECTORY}_{version}.zip"
    with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for file_name in sorted(REQUIRED_FILES):
            info = zipfile.ZipInfo(f"{ADDON_DIRECTORY}/{file_name}", date_time=(1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.create_system = 3
            info.external_attr = (0o100644 & 0xFFFF) << 16
            info.flag_bits = 0
            data = Path(file_name).read_bytes()
            archive.writestr(info, data, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
            if include_hashes:
                print(f"  SHA256 {file_name}: {hashlib.sha256(data).hexdigest()}")

    return archive_path, version


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-o", "--output", default="/tmp", help="Output directory (default: /tmp)")
    parser.add_argument("--no-hash", action="store_true", help="Skip optional SHA256 diagnostics")
    args = parser.parse_args()

    try:
        archive_path, version = package(args.output, include_hashes=not args.no_hash)
    except (OSError, ValueError, zipfile.BadZipFile) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1

    print(f"Using version: {version}")
    print(f"Package created successfully: {archive_path}")
    print("This archive has not been verified in-game; packaging checks do not replace client testing.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
