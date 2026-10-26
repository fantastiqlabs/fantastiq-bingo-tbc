#!/usr/bin/env lua
-- Validate the raid-neutral catalog section without rejecting ordinary WoW terms.
local path = arg and arg[1] or "raid_bingo_catalog.lua"
local file = io.open(path, "r")
if not file then
    io.stderr:write("Cannot open catalog: " .. path .. "\n")
    os.exit(2)
end
local source = file:read("*a")
file:close()

local section = source:match("raid_generic%s*=%s*{(.-)\n%s*},")
if not section then
    io.stderr:write("Cannot find raid_generic catalog section\n")
    os.exit(1)
end

local entries, ids, texts = 0, {}, {}
local errors = {}
local named_encounters = {
    "karazhan", "gruul's lair", "magtheridon's lair", "serpentshrine cavern",
    "tempest keep", "black temple", "mount hyjal", "zul'aman", "sunwell plateau",
    "attumen", "moroes", "maiden of virtue", "curator", "shade of aran",
    "terestian illhoof", "netherspite", "malchezaar", "maulgar", "gruul",
    "magtheridon", "hydross", "lurker below", "leotheras", "karathress",
    "morogrim", "vashj", "al'ar", "void reaver", "solarian", "kael'thas",
    "rage winterchill", "anetheron", "kaz'rogal", "azgalor", "archimonde",
    "naj'entus", "supremus", "akama", "teron gorefiend", "gurtogg bloodboil",
    "reliquary of souls", "mother shahraz", "illidari council", "illidan",
    "nalorakk", "akil'zon", "jan'alai", "halazzi", "malacrass", "zul'jin",
    "kalecgos", "brutallus", "felmyst", "eredar twins", "m'uru", "kil'jaeden",
}
for id, text in section:gmatch('{%s*id%s*=%s*"([^"]+)"%s*,%s*text%s*=%s*"([^"]+)"') do
    entries = entries + 1
    if not id:match("^generic_%d%d%d$") then
        table.insert(errors, "Unexpected generic ID: " .. id)
    end
    if ids[id] then
        table.insert(errors, "Duplicate ID: " .. id)
    end
    ids[id] = true
    local normalized = text:lower():gsub("%s+", " ")
    if texts[normalized] then
        table.insert(errors, "Duplicate text: " .. text)
    end
    texts[normalized] = true
    if #text > 50 then
        table.insert(errors, "Text exceeds 50 characters: " .. id .. " (" .. #text .. ")")
    end
    for _, name in ipairs(named_encounters) do
        if normalized:find(name, 1, true) then
            table.insert(errors, "Named raid or boss in generic text: " .. id .. " (" .. name .. ")")
            break
        end
    end
end

if entries < 100 then
    table.insert(errors, "Expected at least 100 generic entries; found " .. entries)
end
if section:match("%f[%w]raid%s*=") then
    table.insert(errors, "Raid-specific metadata found in raid_generic")
end

if #errors > 0 then
    for _, err in ipairs(errors) do io.stderr:write("ERROR: " .. err .. "\n") end
    os.exit(1)
end
print("raid_generic catalog valid: " .. entries .. " unique raid-neutral entries")
