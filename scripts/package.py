#!/usr/bin/env python3
"""Create a deterministic, versioned Raid Bingo addon ZIP."""

import argparse
import hashlib
import re
import sys
import zipfile
from pathlib import Path

ADDON_DIRECTORY = "raid_bingo_addon"
REQUIRED_FILES = (
    "raid_bingo_addon.toc",
    "raid_bingo_addon.lua",
    "raid_bingo_card.lua",
    "raid_bingo_ui.lua",
    "raid_bingo_utils.lua",
    "raid_bingo_catalog.lua",
)
TOC_VERSION = re.compile(r"^## Version:\s*(\S+)\s*$", re.MULTILINE)


def get_version_from_toc(toc_path=Path("raid_bingo_addon.toc")):
    """Return the single safe addon version declared in the TOC."""
    try:
        contents = toc_path.read_text(encoding="utf-8")
    except OSError as error:
        raise ValueError(f"Could not read {toc_path}: {error}") from error
    versions = TOC_VERSION.findall(contents)
    if len(versions) != 1:
        raise ValueError("TOC must contain exactly one ## Version field")
    version = versions[0]
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._+-]*", version):
        raise ValueError(f"Unsafe TOC version: {version!r}")
    return version


def calculate_file_hash(file_path):
    """Calculate a SHA256 hash for optional package diagnostics."""
    digest = hashlib.sha256()
    with open(file_path, "rb") as source:
        for chunk in iter(lambda: source.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def package(output_dir, name=ADDON_DIRECTORY, include_hashes=False):
    """Build an archive with fixed names, ordering, metadata, and timestamps."""
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", name):
        raise ValueError("Package name must be a simple filename component")
    version = get_version_from_toc()
    for file_name in REQUIRED_FILES:
        if not Path(file_name).is_file():
            raise ValueError(f"Required file not found: {file_name}")

    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    archive_path = output_dir / f"{name}_{version}.zip"
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
    parser.add_argument("-n", "--name", default=ADDON_DIRECTORY, help="Archive filename prefix")
    parser.add_argument("--no-hash", action="store_true", help="Skip optional SHA256 diagnostics")
    args = parser.parse_args()

    try:
        archive_path, version = package(args.output, args.name, include_hashes=not args.no_hash)
    except (OSError, ValueError, zipfile.BadZipFile) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1

    print(f"Using version: {version}")
    print(f"Package created successfully: {archive_path}")
    print("This archive has not been verified in-game; packaging checks do not replace client testing.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
