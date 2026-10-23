-- Raid Bingo Addon Utility Functions for World of Warcraft: The Burning Crusade Anniversary Edition (Interface 20506)
-- This file contains utility functions to support the addon functionality

-- Create the addon namespace
local addonName, addon = ...

-- Utility function to check if a player has completed a line
function addon:IsLineCompleted(playerMarks, lineType, lineNumber)
    -- This is a placeholder for future implementation
    -- For MVP, we're focusing on basic marking and UI
    return false
end

-- Utility function to validate card data
function addon:ValidateCardData(cardData)
    if not cardData or not cardData.squares then
        return false
    end

    -- Check that there are exactly 25 squares
    if #cardData.squares ~= 25 then
        return false
    end

    -- Check that the center square is "Free Space"
    if cardData.squares[13] ~= "Free Space" then
        return false
    end

    return true
end

-- Utility function to format text for display (truncating long texts)
function addon:FormatTextForDisplay(text, maxLength)
    if not text then
        return ""
    end

    if #text <= maxLength then
        return text
    end

    -- Truncate and add ellipsis
    return string.sub(text, 1, maxLength - 3) .. "..."
end

-- Utility function to get the current player's name
function addon:GetPlayerName()
    local playerName = UnitName("player")
    if not playerName then
        playerName = "Unknown"
    end
    return playerName
end

-- Utility function to initialize default card data (if needed)
function addon:InitializeDefaultCardData()
    -- This would be called if no card data exists
    -- For MVP, we're using the fixed card from raid_bingo_card.lua
    return true
end

-- Utility function to reset player marks
function addon:ResetPlayerMarks()
    if RaidBingoDB and RaidBingoDB.playerMarks then
        for i = 1, 25 do
            RaidBingoDB.playerMarks[i] = nil
        end
        print("|cFF00FF00Raid Bingo marks reset!|r")
    else
        print("|cFFFF0000No marks to reset.|r")
    end
end

-- Utility function to check if a square is the free space
function addon:IsFreeSpace(squareIndex)
    return squareIndex == 13  -- Center square (1-based indexing)
end

-- Utility function to get all completed lines for a player
function addon:GetCompletedLines(playerMarks)
    local completedLines = {}

    -- This would be implemented in full version but returning empty table for MVP
    return completedLines
end

-- Utility function to display help information
function addon:ShowHelp()
    print("=== Raid Bingo Addon Help ===")
    print("/rb or /raidbingo - Toggle the bingo card UI")
    print("/rbreset - Reset your marks")
    print("=============================")
end
