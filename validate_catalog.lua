#!/usr/bin/env lua
-- Validate IDs and prompt uniqueness in the decks the addon can build.
local path = arg and arg[1] or "raid_bingo_catalog.lua"
local file = io.open(path, "r")
if not file then
    io.stderr:write("Cannot open catalog: " .. path .. "\n")
    os.exit(2)
end
local source = file:read("*a")
file:close()

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

local pools, pool_names = {}, {}
for pool_name, section in source:gmatch("\n    ([%w_]+)%s*=%s*{\n(.-)\n    },") do
    pools[pool_name] = { entries = {}, source = section }
    table.insert(pool_names, pool_name)
    for id, text in section:gmatch('{%s*id%s*=%s*"([^"]+)"%s*,%s*text%s*=%s*"([^"]+)"') do
        table.insert(pools[pool_name].entries, { id = id, text = text })
    end
end

local errors = {}
local generic = pools.raid_generic
if not generic then
    io.stderr:write("Cannot find raid_generic catalog section\n")
    os.exit(1)
end
if #pool_names == 0 then
    io.stderr:write("Cannot find catalog pools\n")
    os.exit(1)
end

local categories = { class_role = true, mechanics = true, funny = true }
local all_ids, global_texts = {}, {}
local generic_texts = {}
local global_unique, generic_entries = 0, #generic.entries
for _, entry in ipairs(generic.entries) do
    local key = entry.text:lower():gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    generic_texts[key] = true
end

for _, pool_name in ipairs(pool_names) do
    local pool = pools[pool_name]
    local pool_ids, pool_texts = {}, {}
    local unique_texts = 0
    if #pool.entries == 0 then
        table.insert(errors, "No catalog entries found in " .. pool_name)
    end

    for _, entry in ipairs(pool.entries) do
        local id, text = entry.id, entry.text
        if pool_ids[id] then
            table.insert(errors, "Duplicate ID in " .. pool_name .. ": " .. id)
        elseif all_ids[id] then
            table.insert(errors, "Duplicate ID across pools: " .. id .. " (found in both " .. all_ids[id] .. " and " .. pool_name .. ")")
        end
        pool_ids[id] = true
        all_ids[id] = all_ids[id] or pool_name

        local normalized = text:lower():gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        if pool_texts[normalized] then
            table.insert(errors, "Duplicate text in " .. pool_name .. ": " .. text)
        end
        if pool_name ~= "raid_generic" and not categories[pool_name] and generic_texts[normalized] then
            table.insert(errors, "Duplicate text between " .. pool_name .. " and raid_generic: " .. text)
        end
        if not pool_texts[normalized] then unique_texts = unique_texts + 1 end
        pool_texts[normalized] = true
        if not global_texts[normalized] then global_unique = global_unique + 1 end
        global_texts[normalized] = true

        if #text > 50 then
            table.insert(errors, "Text exceeds 50 characters in " .. pool_name .. ": " .. id .. " (" .. #text .. ")")
        end
        if pool_name == "raid_generic" then
            if not id:match("^generic_%d%d%d$") then
                table.insert(errors, "Unexpected generic ID: " .. id)
            end
            for _, name in ipairs(named_encounters) do
                if normalized:find(name, 1, true) then
                    table.insert(errors, "Named raid or boss in generic text: " .. id .. " (" .. name .. ")")
                    break
                end
            end
        end
    end

    print(string.format("%s: %d entries, %d unique texts", pool_name, #pool.entries, unique_texts))
end

if generic_entries < 100 then
    table.insert(errors, "Expected at least 100 generic entries; found " .. generic_entries)
end
if generic.source:match("%f[%w]raid%s*=") then
    table.insert(errors, "Raid-specific metadata found in raid_generic")
end
print("Total unique text entries across all pools: " .. global_unique)

if #errors > 0 then
    for _, err in ipairs(errors) do io.stderr:write("ERROR: " .. err .. "\n") end
    os.exit(1)
end
print("Catalog valid: raid_generic and every raid-specific deck contain unique text")
