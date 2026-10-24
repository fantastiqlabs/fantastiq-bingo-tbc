# Issue 6: Development, testing, packaging, and release workflow

## Current workflow

- Keep the addon standalone in this repository, with Lua modules and `raid_bingo_addon.toc` at the archive root.
- Target TOC interface `20506`; recheck against the live Anniversary client before a stable release.
- Keep changes small, use isolated task branches/worktrees, and open focused PRs.
- Publish versioned GitHub prereleases for owner testing. A prerelease is not a stable release or proof of in-client compatibility.
- Validate source/catalog rules and ZIP contents where tooling is available. Record missing Lua parser/runtime checks explicitly.
- Run [SMOKE_TEST_CHECKLIST.md](SMOKE_TEST_CHECKLIST.md) in the game client before claiming runtime compatibility.

## Release gates

A candidate should have a focused PR, passing available automated/static checks, a verified archive containing the expected addon folder and TOC, signed release notes, and a clear list of owner-only checks. Do not claim an in-game test unless the owner reports it.

## Versioning

Use sequential `v0.1.0-rc.N` tags for test candidates. Promote to a stable version only after the owner completes the smoke test and confirms the candidate works.
