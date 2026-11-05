#!/usr/bin/env lua
-- Load and validate the data file with the same addon table shape used in game.
local path = arg and arg[1] or "wow_forever/fantastiq_bingo_forever_catalog.lua"
local addon = {}
local chunk, load_error = loadfile(path)
if not chunk then
    io.stderr:write("Cannot load Forever catalog: " .. tostring(load_error) .. "\n")
    os.exit(2)
end

local ok, runtime_error = pcall(chunk, "fantastiq_bingo_forever", addon)
if not ok then
    io.stderr:write("Cannot evaluate Forever catalog: " .. tostring(runtime_error) .. "\n")
    os.exit(2)
end

local catalog = addon.catalog
local errors, ids, texts = {}, {}, {}
local valid_categories = {
    leveling = true,
    exploration = true,
    quest = true,
    social = true,
    dungeon = true,
    moment = true,
}
local valid_modes = { solo = true, group = true }
local bands = {
    { min = 1, max = 10 },
    { min = 11, max = 20 },
    { min = 21, max = 30 },
    { min = 31, max = 40 },
    { min = 41, max = 50 },
    { min = 51, max = 60 },
}

if type(catalog) ~= "table" or #catalog == 0 then
    io.stderr:write("Forever catalog must contain at least one objective\n")
    os.exit(1)
end

for index, item in ipairs(catalog) do
    local prefix = "objective " .. index .. ": "
    if type(item.id) ~= "string" or item.id == "" then
        table.insert(errors, prefix .. "missing stable ID")
    elseif ids[item.id] then
        table.insert(errors, prefix .. "duplicate ID " .. item.id)
    else
        ids[item.id] = true
    end

    if not valid_categories[item.category] then
        table.insert(errors, prefix .. "invalid category " .. tostring(item.category))
    end
    if type(item.text) ~= "string" or item.text:match("^%s*$") then
        table.insert(errors, prefix .. "missing objective text")
    else
        local normalized = item.text:lower():gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        if texts[normalized] then
            table.insert(errors, prefix .. "duplicate objective text " .. item.text)
        else
            texts[normalized] = true
        end
    end

    if type(item.modes) ~= "table" or #item.modes == 0 then
        table.insert(errors, prefix .. "must support solo, group, or both")
    else
        local seen_modes = {}
        for _, mode in ipairs(item.modes) do
            if not valid_modes[mode] then
                table.insert(errors, prefix .. "invalid mode " .. tostring(mode))
            elseif seen_modes[mode] then
                table.insert(errors, prefix .. "duplicate mode " .. mode)
            end
            seen_modes[mode] = true
        end
    end

    if type(item.minLevel) ~= "number" or type(item.maxLevel) ~= "number"
        or item.minLevel < 1 or item.maxLevel > 60 or item.minLevel > item.maxLevel then
        table.insert(errors, prefix .. "level range must be within 1-60 and ordered")
    end
    if item.marking ~= "manual" and item.marking ~= "verified_event" then
        table.insert(errors, prefix .. "marking must be manual or verified_event")
    end
    if item.marking == "verified_event" and type(item.event) ~= "string" then
        table.insert(errors, prefix .. "verified-event objectives must name their event")
    end
    if item.region ~= nil and (type(item.region) ~= "string" or item.region == "") then
        table.insert(errors, prefix .. "region must be a non-empty string when provided")
    end
    if item.dungeon ~= nil and (type(item.dungeon) ~= "string" or item.dungeon == "") then
        table.insert(errors, prefix .. "dungeon must be a non-empty string when provided")
    end
end

local minimum_board_pool = 25
for _, mode in ipairs({ "solo", "group" }) do
    for _, band in ipairs(bands) do
        local eligible = 0
        for _, item in ipairs(catalog) do
            local supports_mode = false
            for _, item_mode in ipairs(item.modes or {}) do
                if item_mode == mode then supports_mode = true end
            end
            if supports_mode and type(item.minLevel) == "number" and type(item.maxLevel) == "number"
                and item.minLevel <= band.max and item.maxLevel >= band.min then
                eligible = eligible + 1
            end
        end
        if eligible < minimum_board_pool then
            table.insert(errors, string.format("%s board at levels %d-%d has only %d eligible objectives; need %d",
                mode, band.min, band.max, eligible, minimum_board_pool))
        end
    end
end

local categories = {}
for _, item in ipairs(catalog) do categories[item.category] = true end
for category in pairs(valid_categories) do
    if not categories[category] then
        table.insert(errors, "Missing objective pool for category " .. category)
    end
end

if #errors > 0 then
    for _, message in ipairs(errors) do io.stderr:write("ERROR: " .. message .. "\n") end
    os.exit(1)
end

print(string.format("Forever catalog valid: %d objectives, unique IDs/text, solo/group pools cover levels 1-60", #catalog))
