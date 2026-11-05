local addonName, addon = ...
addonName = addonName or "fantastiq_bingo_forever"
addon = addon or {}
local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, loadedName)
    if event ~= "ADDON_LOADED" or loadedName ~= addonName then
        return
    end

    addon.InitializeSavedVariables()

    local savedCount = #addon.db.history
    print(("Fantastiq Bingo Forever loaded. Saved boards: %d. Use /fqb solo|group <min> <max> [seed]."):format(savedCount))
end)

SLASH_FANTASTIQBINGOFOREVER1 = "/fqb"
SlashCmdList.FANTASTIQBINGOFOREVER = function(message)
    local mode, minText, maxText, seedText = (message or ""):match("^(%a+)%s+(%d+)%s+(%d+)%s*(%d*)$")
    if mode then
        local board, err = addon.OpenBoard(mode:lower(), tonumber(minText), tonumber(maxText), seedText ~= "" and tonumber(seedText) or nil)
        if not board then
            print("Fantastiq Bingo Forever: " .. err)
            return
        end
        print(("Created %s board for levels %d-%d. Share seed: %d. Squares: 24 + free space."):format(
            board.mode, board.minLevel, board.maxLevel, board.seed
        ))
        return
    end

    local current = addon.db and addon.db.currentBoardId and addon.LoadBoard(addon.db.currentBoardId)
    if current then
        local marked = 0
        for _, cell in ipairs(current.cells) do
            if cell.mark then marked = marked + 1 end
        end
        print(("Current %s board, levels %d-%d, seed %d: %d of 25 marked."):format(
            current.mode, current.minLevel, current.maxLevel, current.seed, marked
        ))
    else
        print("Use /fqb solo|group <minLevel> <maxLevel> [seed] to create a reproducible board.")
    end
    local version, build, buildDate, interface = GetBuildInfo()
    print(("Fantastiq Bingo Forever | client %s (%s), interface %s"):format(
        tostring(version), tostring(build), tostring(interface)
    ))
    if addon.db and addon.db.recoveryNotice then print(addon.db.recoveryNotice) end
end
