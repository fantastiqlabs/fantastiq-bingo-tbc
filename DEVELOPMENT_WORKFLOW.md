# Raid Bingo Development and Release Workflow

Raid Bingo is a standalone World of Warcraft: The Burning Crusade Classic Anniversary addon. Its source and release process do not depend on the HelloThereGuild portal.

## Source and client baseline

- The addon archive contains `raid_bingo_addon/` at its root, with `raid_bingo_addon.toc` and the Lua files listed in the TOC.
- The target interface is `20506`, as checked by `scripts/package_contract.py`.
- The current candidate uses local SavedVariables. It does not send card or mark data to a service.
- The candidate has not been verified in the game client. Use [INSTALL_GUIDE.md](INSTALL_GUIDE.md) and record the result in [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md).

## Checks and packaging

Run these from the repository root:

```bash
lua validate_catalog.lua
python3 scripts/package.py --output /tmp/raid-bingo
python3 scripts/verify.py /tmp/raid-bingo/raid_bingo_addon_<version>.zip
```

The catalog validator checks generic IDs and text for duplicates, a minimum of 100 generic squares, a 50-character limit, and named raid/boss references. The packager creates a deterministic ZIP from the required file list; the verifier checks its exact contents, safe paths, TOC metadata, and CRC. These checks do not exercise the WoW UI or prove client compatibility.

For the in-game portion, use the existing [smoke-test checklist](SMOKE_TEST_CHECKLIST.md) rather than maintaining a second copy here. It covers install/load, raid selectors, sizing, saved settings, automark, square state, and bingo announcements.

## Version and release gates

The TOC version and release tag/archive name must describe the same candidate. As of this workflow review, main declares `1.0.0-rc.3` in the TOC while the latest GitHub prerelease is `v1.0.0-rc.5` with a `raid_bingo_addon_1.0.0-rc.5.zip` asset. Preserve existing releases; reconcile the source metadata before creating the next release, and build and verify the archive from the exact commit being tagged.

Use versioned GitHub prereleases for owner testing. A stable release requires all repository checks, an archive that passes verification, and a passing owner smoke test in the Anniversary client. Do not describe a prerelease as client-verified until that test is recorded. No automatic in-game update checker is present; players download updates from GitHub and follow [INSTALL_GUIDE.md](INSTALL_GUIDE.md).

## License status

There is no `LICENSE` file in the repository, so no permissive license has been selected or declared. Do not describe the addon as MIT, permissively licensed, or available for redistribution under terms that are not in the repository. Record a license decision before making such a claim.

## Contribution routine

1. Keep implementation work small and isolated in a branch/worktree.
2. Run the catalog and package checks relevant to the change.
3. Open a focused PR with behavior, validation, and any owner-only client checks stated clearly.
4. Merge only after reviewing the diff and current-head checks.
5. Publish a new prerelease from the merged commit when a testable addon change is ready; include a concise changelog and the exact ZIP.
