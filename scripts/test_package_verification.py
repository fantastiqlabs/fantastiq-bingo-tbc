#!/usr/bin/env python3
"""Focused package and verifier regression checks using isolated ZIP fixtures."""

import subprocess
import sys
import tempfile
import unittest
import warnings
import zipfile
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
from verify import ADDON_DIRECTORY, REQUIRED_FILES  # noqa: E402

VALID_TOC = (
    "## Interface: 20506\n"
    "## Version: 1.0.0-rc.1\n"
    "raid_bingo_addon.lua\n"
)


class PackageVerificationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.output = self.root / "output"
        for name in REQUIRED_FILES:
            content = VALID_TOC if name.endswith(".toc") else f"fixture:{name}\n"
            (self.root / name).write_text(content, encoding="utf-8")

    def run_script(self, script, *args):
        return subprocess.run(
            [sys.executable, str(SCRIPT_DIR / script), *map(str, args)],
            cwd=self.root,
            capture_output=True,
            text=True,
            check=False,
        )

    def package_fixture(self):
        result = self.run_script("package.py", "--output", self.output, "--no-hash")
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        return self.output / "raid_bingo_addon_1.0.0-rc.1.zip"

    def entries(self, toc=VALID_TOC):
        return {
            f"{ADDON_DIRECTORY}/{name}": toc if name.endswith(".toc") else f"fixture:{name}\n"
            for name in REQUIRED_FILES
        }

    def write_archive(self, path, entries=None, extra=(), duplicate=False):
        contents = self.entries() if entries is None else dict(entries)
        with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_STORED) as archive:
            for name, value in contents.items():
                archive.writestr(name, value)
            for name, value in extra:
                archive.writestr(name, value)
            if duplicate:
                first_name = next(iter(contents))
                archive.writestr(first_name, contents[first_name])

    def test_packager_creates_verifiable_exact_installable_archive(self):
        archive = self.package_fixture()
        result = self.run_script("verify.py", archive)
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)

        with zipfile.ZipFile(archive) as package:
            self.assertEqual(set(package.namelist()), {
                f"{ADDON_DIRECTORY}/{name}" for name in REQUIRED_FILES
            })

    def test_packager_output_is_reproducible_across_source_mtime_changes(self):
        archive = self.package_fixture()
        first = archive.read_bytes()
        (self.root / "raid_bingo_addon.lua").touch()
        second_archive = self.package_fixture()
        self.assertEqual(second_archive.read_bytes(), first)

    def test_verifier_rejects_unsafe_paths(self):
        archive = self.root / "raid_bingo_addon_1.0.0-rc.1.zip"
        self.write_archive(archive, extra=[("raid_bingo_addon/../escape.lua", "bad")])
        result = self.run_script("verify.py", archive)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unsafe archive path", result.stderr)

    def test_verifier_rejects_duplicate_and_unexpected_entries(self):
        archive = self.root / "raid_bingo_addon_1.0.0-rc.1.zip"
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", UserWarning)
            self.write_archive(archive, duplicate=True)
        result = self.run_script("verify.py", archive)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Duplicate archive paths", result.stderr)

        self.write_archive(archive, extra=[("raid_bingo_addon/notes.txt", "not installable")])
        result = self.run_script("verify.py", archive)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Archive file set mismatch", result.stderr)

    def test_verifier_rejects_wrong_folder_interface_and_version(self):
        archive = self.root / "raid_bingo_addon_1.0.0-rc.1.zip"
        self.write_archive(archive, extra=[("wrong-folder/file.lua", "bad")])
        result = self.run_script("verify.py", archive)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unexpected addon path", result.stderr)

        self.write_archive(archive, entries=self.entries(VALID_TOC.replace("20506", "00000")))
        result = self.run_script("verify.py", archive)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("interface version 20506", result.stderr)

        self.write_archive(archive, entries=self.entries(VALID_TOC.replace("1.0.0-rc.1", "1.0.0-rc.2")))
        result = self.run_script("verify.py", archive)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Expected archive filename", result.stderr)

    def test_verifier_rejects_wrong_archive_name_with_matching_toc(self):
        archive = self.root / "unrelated_1.0.0-rc.1.zip"
        self.write_archive(archive)
        result = self.run_script("verify.py", archive)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Expected archive filename", result.stderr)

    def test_verifier_checks_crc(self):
        archive = self.root / "raid_bingo_addon_1.0.0-rc.1.zip"
        self.write_archive(archive)
        with zipfile.ZipFile(archive) as package:
            info = package.infolist()[0]
            data_offset = info.header_offset + 30 + len(info.filename.encode()) + len(info.extra)
        with archive.open("r+b") as file:
            file.seek(data_offset)
            original = file.read(1)
            file.seek(data_offset)
            file.write(bytes([original[0] ^ 0xFF]))
        result = self.run_script("verify.py", archive)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("CRC check failed", result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
