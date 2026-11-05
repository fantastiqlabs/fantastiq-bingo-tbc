local addonName = "fantastiq_bingo_forever"
local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, loadedName)
    if event ~= "ADDON_LOADED" or loadedName ~= addonName then
        return
    end

    FantastiqBingoForeverDB = FantastiqBingoForeverDB or {
        schemaVersion = 1,
        boards = {},
    }

    print("Fantastiq Bingo Forever compatibility target loaded. Use /fqb for status.")
end)

SLASH_FANTASTIQBINGOFOREVER1 = "/fqb"
SlashCmdList.FANTASTIQBINGOFOREVER = function()
    local version, build, buildDate, interface = GetBuildInfo()
    print(("Fantastiq Bingo Forever | client %s (%s), interface %s"):format(
        tostring(version), tostring(build), tostring(interface)
    ))
    print("This compatibility scaffold does not contain the Bingo board UI yet.")
end
