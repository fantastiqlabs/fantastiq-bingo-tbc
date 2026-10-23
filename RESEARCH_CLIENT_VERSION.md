# TBC Classic Anniversary client target

## Finding

The addon target is Burning Crusade Classic Anniversary, patch 2.5.6, TOC interface `20506` (as of October 2026). Interface `11201` is not the Anniversary client target and was a mistaken value in the initial addon metadata. `raid_bingo_addon.toc` now declares `## Interface: 20506`.

## Evidence

- Blizzard Community Manager post, “User Interface Updates in Classic,” says Burning Crusade Classic Anniversary moved from patch 2.5.5 to 2.5.6: https://www.bluetracker.gg/wow/topic/eu-en/623628-user-interface-updates-in-classic/
- Warcraft Wiki’s current client build table lists Burning Crusade Classic Anniversary 2.5.6 with interface `20506`: https://warcraft.wiki.gg/wiki/Public_client_builds
- Interface numbers can be checked in-client with `/dump select(4, GetBuildInfo())`: https://warcraft.wiki.gg/wiki/Getting_the_current_interface_number

## Verification status

The target is based on published client-version references. No game client is available in this workspace, so the addon has not yet been loaded or smoke-tested in-game. Confirm the exact live interface value in the owner's client before tagging a release; Blizzard can change it in a later patch.
