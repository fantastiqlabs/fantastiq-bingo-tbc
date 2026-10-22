-- Raid Bingo Addon for World of Warcraft: The Burning Crusade (1.12.1)
-- Main addon file

-- Create the addon namespace
local addonName, addon = ...

-- Card data - this will be defined in raid_bingo_card.lua
local cardData = nil;

-- Player's marking state
local playerMarks = {};

-- Current deck selection (will be set based on raid type)
local currentDeck = "default";

-- Initialize the addon
function addon:OnEnable()
    -- Load saved variables if they exist
    if not RaidBingoDB then
        RaidBingoDB = {};
    end

    if not RaidBingoDB.playerMarks then
        RaidBingoDB.playerMarks = {};
    end

    playerMarks = RaidBingoDB.playerMarks;

    -- Create the UI when the addon loads
    self:CreateUI();

    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("ADDON_LOADED");

    -- Print a welcome message
    print("|cFF00FF00Raid Bingo Addon loaded!|r");
end

-- Generate a random bingo card from the catalog
function addon:GenerateCardFromCatalog(deckName)
    -- Check if RaidBingoCatalog is available
    if not RaidBingoCatalog then
        print("Warning: RaidBingoCatalog not available, using default card")
        return self:GetDefaultCard()
    end
    
    -- Get the deck from the catalog (raid name -> array of squares)
    local deck = RaidBingoCatalog[deckName]
    if not deck then
        -- Fallback to default deck - use a generic raid or just return default
        print("Warning: Deck '" .. deckName .. "' not found, using default card")
        return self:GetDefaultCard()
    end
    
    -- Ensure the deck is actually an array
    if type(deck) ~= "table" then
        print("Warning: Deck '" .. deckName .. "' is not a valid table, using default card")
        return self:GetDefaultCard()
    end
    
    -- Create a new card with 25 squares (5x5)
    local newCard = {
        squares = {},
        gridSize = 5,
        centerSquareIndex = 13
    }
    
    -- Get random squares from the deck
    local availableSquares = {}
    
    -- Copy all squares from the deck (the deck is already an array of squares)
    for i, square in ipairs(deck) do
        table.insert(availableSquares, square)
    end
    
    -- Shuffle the squares
    self:ShuffleTable(availableSquares)
    
    -- Take first 24 squares (excluding center)
    local selectedSquares = {}
    for i = 1, math.min(24, #availableSquares) do
        table.insert(selectedSquares, availableSquares[i])
    end
    
    -- Fill the card with squares (center is "Free Space")
    for i = 1, 25 do
        if i == 13 then
            newCard.squares[i] = "Free Space"
        else
            if #selectedSquares > 0 then
                newCard.squares[i] = table.remove(selectedSquares)
            else
                -- Fallback to default text if we run out of squares
                newCard.squares[i] = { id = "fallback", text = "Random Bingo Square", category = "fallback" }
            end
        end
    end
    
    return newCard
end

-- Get a default card for fallback
function addon:GetDefaultCard()
    return {
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
        gridSize = 5,
        centerSquareIndex = 13
    }
end

-- Shuffle a table (Fisher-Yates shuffle)
function addon:ShuffleTable(t)
    local n = #t
    
    while n > 1 do
        local k = math.random(n)
        t[n], t[k] = t[k], t[n]
        n = n - 1
    end
end

-- Handle addon loading event
function addon:OnAddonLoaded(event, addonName)
    if addonName == "raid_bingo_addon" then
        self:OnEnable();
    end
end

-- Create the main UI frame
function addon:CreateUI()
    -- Create the main frame
    local frame = CreateFrame("Frame", "RaidBingoFrame", UIParent);
    frame:SetSize(400, 500);
    frame:SetPoint("CENTER");
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 11, top = 11, bottom = 11 }
    });
    frame:SetBackdropColor(0, 0, 0, 0.8);

    -- Make it movable
    frame:EnableMouse(true);
    frame:SetMovable(true);
    frame:RegisterForDrag("LeftButton");
    frame:SetScript("OnDragStart", frame.StartMoving);
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing);

    -- Title text
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
    title:SetPoint("TOP", 0, -10);
    title:SetText("Raid Bingo Card");

    -- Close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton");
    closeButton:SetPoint("TOPRIGHT", -5, -5);
    closeButton:SetScript("OnClick", function()
        frame:Hide();
    end);

    -- Store reference to the main frame for later use
    self.mainFrame = frame;
    
    -- Generate a card based on current deck
    self:GenerateAndDisplayCard();
end

-- Generate and display a card
function addon:GenerateAndDisplayCard()
    -- Generate card from catalog
    local generatedCard = self:GenerateCardFromCatalog(currentDeck)
    cardData = generatedCard
    
    -- Update UI with the new card data
    if self.mainFrame then
        self:UpdateUI()
    end
end

-- Toggle UI visibility
function addon:ToggleUI()
    if not self.mainFrame then
        self:CreateUI();
    end

    if self.mainFrame:IsVisible() then
        self.mainFrame:Hide();
    else
        self.mainFrame:Show();
        -- Update the card when showing
        self:UpdateUI();
    end
end

-- Mark a square as complete
function addon:MarkSquare(squareIndex)
    -- Toggle the mark state
    if not playerMarks[squareIndex] then
        playerMarks[squareIndex] = true;
    else
        playerMarks[squareIndex] = false;
    end

    -- Save to saved variables
    RaidBingoDB.playerMarks = playerMarks;

    -- Update UI to reflect the change
    self:UpdateUI();
end

-- Check if a square is marked
function addon:IsSquareMarked(squareIndex)
    return playerMarks[squareIndex] or false;
end

-- Check for completed lines (horizontal, vertical only - no diagonals for MVP)
function addon:CheckLines()
    local lines = {};

    -- Horizontal lines (5 rows)
    for row = 0, 4 do
        local isComplete = true;
        for col = 0, 4 do
            local index = row * 5 + col + 1;
            if not playerMarks[index] then
                isComplete = false;
                break;
            end
        end
        if isComplete then
            table.insert(lines, "row_" .. row);
        end
    end

    -- Vertical lines (5 columns)
    for col = 0, 4 do
        local isComplete = true;
        for row = 0, 4 do
            local index = row * 5 + col + 1;
            if not playerMarks[index] then
                isComplete = false;
                break;
            end
        end
        if isComplete then
            table.insert(lines, "col_" .. col);
        end
    end

    -- Diagonal lines are NOT implemented for MVP as per requirements
    
    return lines;
end

-- Update the UI to show current marks and completed lines
function addon:UpdateUI()
    -- This function is now handled by the UI component which has direct access to cardData
    if self.mainFrame then
        -- The UI component handles updating itself with the current card data
        print("Updating UI with card data...");
        -- Trigger UI update in the UI component - let the UI handle its own updates
        if self.mainFrame and self.mainFrame.UpdateCard then
            self.mainFrame:UpdateCard()
        end
    end
end

-- Command handler for slash commands
function addon:HandleCommand(msg)
    if msg == "toggle" then
        self:ToggleUI();
    elseif msg == "reset" then
        playerMarks = {};
        RaidBingoDB.playerMarks = playerMarks;
        self:UpdateUI();
        print("Raid Bingo marks reset.");
    elseif msg == "bt" then
        -- Switch to Black Temple deck
        currentDeck = "black_temple"
        self:GenerateAndDisplayCard()
        print("Switched to Black Temple bingo card.")
    elseif msg == "hyjal" then
        -- Switch to Mount Hyjal deck
        currentDeck = "mount_hyjal"
        self:GenerateAndDisplayCard()
        print("Switched to Mount Hyjal bingo card.")
    elseif msg == "ssc" then
        -- Switch to SSC deck
        currentDeck = "ssc"
        self:GenerateAndDisplayCard()
        print("Switched to SSC bingo card.")
    elseif msg == "tk" then
        -- Switch to Tempest Keep/Kael'thas deck
        currentDeck = "tempest_keep"
        self:GenerateAndDisplayCard()
        print("Switched to Tempest Keep/Kael'thas bingo card.")
    else
        print("Available commands:");
        print("/rb toggle - Toggle the bingo card UI");
        print("/rb reset - Reset all your marks");
        print("/rb bt - Switch to Black Temple deck");
        print("/rb hyjal - Switch to Mount Hyjal deck");
        print("/rb ssc - Switch to SSC deck");
        print("/rb tk - Switch to Tempest Keep/Kael'thas deck");
    end
end

-- Register slash command
SLASH_RAIDBINGO1 = "/rb";
SlashCmdList["RAIDBINGO"] = function(msg)
    addon:HandleCommand(msg);
end;

-- Event handling
function addon:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:OnEnable();
    elseif event == "ADDON_LOADED" then
        local name = ...;
        if name == "raid_bingo_addon" then
            self:OnEnable();
        end
    end
end

-- Set up the event handler
addon:SetScript("OnEvent", addon.OnEvent);

-- Initialize the addon when loaded
local function OnAddonLoad()
    addon:OnEnable();
end

-- Register for the ADDON_LOADED event to initialize properly
local frame = CreateFrame("Frame");
frame:RegisterEvent("ADDON_LOADED");
frame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == "raid_bingo_addon" then
        OnAddonLoad();
    end
end);

-- Export the addon for use by other modules
RaidBingoAddon = addon;
