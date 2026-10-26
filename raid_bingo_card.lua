-- Raid Bingo Card Definition for World of Warcraft: The Burning Crusade Anniversary Edition (Interface 20506)
-- This defines the fixed 5x5 bingo card with predefined content

-- Create the addon namespace
local addonName, addon = ...

-- Define the bingo card content
local bingoCard = {
    -- 25 squares in a 5x5 grid (1-25)
    -- Center square is always "Free Space"
    squares = {
        "Defeat a boss in the raid",
        "Get a specific achievement during raid",
        "Complete a specific encounter without wipes",
        "Kill a certain number of mobs",
        "Use a specific ability or spell",
        "Reach a certain amount of damage/healing",
        "Complete a specific mechanic",
        "Obtain a rare item drop",
        "Achieve a specific stat threshold",
        "Defeat the first boss in the raid",
        "Get 50% health on a boss",
        "Free Space", -- Center square
        "Kill 10+ mobs in one encounter",
        "Complete all adds in an encounter",
        "Use a class ability during raid",
        "Deal 100k damage to a single target",
        "Heal for 50k total in raid",
        "Get a specific debuff on boss",
        "Achieve full raid completion",
        "Defeat the final boss without wipes",
        "Complete all objectives in encounter",
        "Kill a named mob",
        "Use a consumable during raid",
        "Get a critical hit during raid",
        "Reach 100% health on a boss"
    },

    -- Card structure (5x5 grid)
    gridSize = 5,

    -- Center square index (3rd row, 3rd column) - 1-based indexing
    centerSquareIndex = 13
}

-- Export the card data for use by other modules
RaidBingoCard = bingoCard;

-- Function to get a specific square's content
function addon:GetSquareContent(squareIndex)
    if not bingoCard.squares[squareIndex] then
        return "Unknown";
    end
    return bingoCard.squares[squareIndex];
end

-- Function to get card dimensions
function addon:GetCardDimensions()
    return bingoCard.gridSize, bingoCard.gridSize;
end

-- Function to get all squares
function addon:GetAllSquares()
    return bingoCard.squares;
end
