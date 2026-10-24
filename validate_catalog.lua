#!/usr/bin/env lua
-- Catalog validator for Raid Bingo Addon
-- Checks: unique IDs, generic-pool count ≥100, duplicate text, forbidden raid/boss terms

local function validate_catalog(catalog_path)
    local file = io.open(catalog_path, "r")
    if not file then
        print("ERROR: Cannot open catalog file: " .. catalog_path)
        return false
    end

    local content = file:read("*all")
    file:close()

    local errors = {}
    local warnings = {}

    -- Extract raid_generic section
    local raid_generic_section = content:match("raid%s*=%s*%{(.-)\n%s*%}")

    if not raid_generic_section then
        print("ERROR: Could not find raid_generic section")
        return false
    end

    -- Extract all entries
    local entries = {}
    for entry in raid_generic_section:gmatch("%{%s*id%s*=%s*["'](.-)["']%s*,%s*text%s*=%s*["'](.-)["']") do
        local id, text = entry:match("(%S+)%s*,%s*(.-)$")
        if id and text then
            table.insert(entries, {id = id, text = text})
        end
    end

    -- Check count
    local count = #entries
    if count < 100 then
        table.insert(errors, string.format("raid_generic pool has %d entries, needs at least 100", count))
    else
        print(string.format("✓ raid_generic pool has %d entries (≥100)", count))
    end

    -- Check for duplicate IDs
    local seen_ids = {}
    for _, entry in ipairs(entries) do
        if seen_ids[entry.id] then
            table.insert(errors, "Duplicate ID found: " .. entry.id)
        end
        seen_ids[entry.id] = true
    end
    if next(seen_ids) then
        print("✓ All IDs are unique")
    end

    -- Check for duplicate text
    local seen_text = {}
    for _, entry in ipairs(entries) do
        if seen_text[entry.text] then
            table.insert(errors, "Duplicate text found: " .. entry.text)
        end
        seen_text[entry.text] = true
    end
    if next(seen_text) then
        print("✓ No duplicate text entries")
    end

    -- Check for forbidden terms (case-insensitive)
    local forbidden_terms = {
        "black temple", "illidan", "gurtogg", "shahraz", "najentus", "supremus", "teron", "akama",
        "mount hyjal", "rage winterchill", "anetheron", "kazrogal", "azgalor", "archimonde",
        "serpentshrine", "fathom-lord", "karathress", "vashj", "morogrim", "tidewalker", "hydross",
        "tempest keep", "kael'thas", "kael", "void reaver", "skarloc", "nexus-stalker", "illidari",
        "zul'am", "nalorakk", "akil'zon", "jan'alai", "halazzi", "malacrass", "zul'jin",
        "blackrock", "onion", "pyre", "temple", "hyjal", "ssc", "tk", "bt", "za",
    }

    local found_forbidden = {}
    for _, entry in ipairs(entries) do
        local text_lower = entry.text:lower()
        for _, term in ipairs(forbidden_terms) do
            if text_lower:find(term, 1, true) then
                table.insert(warnings, string.format("Entry '%s' may contain forbidden term '%s'", entry.text, term))
                if not found_forbidden[term] then
                    found_forbidden[term] = true
                end
            end
        end
    end

    if next(found_forbidden) then
        print("WARNING: Found entries with potential forbidden terms:")
        for term in pairs(found_forbidden) do
            print("  - " .. term)
        end
    else
        print("✓ No forbidden raid/boss terms found")
    end

    -- Print results
    print("\n=== VALIDATION RESULTS ===")
    if #errors > 0 then
        print("ERRORS (" .. #errors .. "):")
        for _, err in ipairs(errors) do
            print("  ✗ " .. err)
        end
    else
        print("No errors found!")
    end

    if #warnings > 0 then
        print("WARNINGS (" .. #warnings .. "):")
        for _, warn in ipairs(warnings) do
            print("  ! " .. warn)
        end
    end

    return #errors == 0
end

-- Run validation
local catalog_path = arg and arg[1] or "raid_bingo_catalog.lua"
local success = validate_catalog(catalog_path)

if success then
    print("\n✓ Catalog validation PASSED")
    os.exit(0)
else
    print("\n✗ Catalog validation FAILED")
    os.exit(1)
end
