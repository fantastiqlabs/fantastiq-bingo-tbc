-- Raid Bingo Addon for World of Warcraft: The Burning Crusade Anniversary Edition (Interface 20506)
-- Main addon file

-- Create the addon namespace
local addonName, addon = ...

-- Card data - this will be defined in raid_bingo_card.lua
local cardData = nil;

-- Player's marking state
local playerMarks = {};

-- Current deck selection (will be set based on raid type)
local currentDeck = "raid_generic";

-- Initialize saved state and create the interface once the addon files are loaded.
function addon:OnEnable()
    RaidBingoDB = RaidBingoDB or {}
    RaidBingoDB.playerMarks = RaidBingoDB.playerMarks or {}
    playerMarks = RaidBingoDB.playerMarks

    if RaidBingoCatalog and RaidBingoCatalog[RaidBingoDB.selectedDeck] then
        currentDeck = RaidBingoDB.selectedDeck
    end

    self:CreateUI()
    print("|cFF00FF00Raid Bingo Addon loaded. Marks are self-reported and private.|r")
end

-- Generate a complete card without duplicate squares. Short raid pools are topped up
-- from the raid-generic pool; the generic deck itself never includes raid-specific text.
function addon:GenerateCardFromCatalog(deckName)
    local deck = RaidBingoCatalog and RaidBingoCatalog[deckName]
    if type(deck) ~= "table" then
        print("Unknown deck; using the raid-generic pool.")
        deckName = "raid_generic"
        deck = RaidBingoCatalog and RaidBingoCatalog[deckName]
    end
    if type(deck) ~= "table" then
        return self:GetDefaultCard()
    end

    local pool = {}
    local seenIds, seenText = {}, {}
    local function addSquares(source)
        for _, square in ipairs(source or {}) do
            local textKey = square and square.text and string.lower(square.text)
            if square and square.id and textKey and not seenIds[square.id] and not seenText[textKey] then
                seenIds[square.id] = true
                seenText[textKey] = true
                table.insert(pool, square)
            end
        end
    end
    addSquares(deck)
    if #pool < 24 and deckName ~= "raid_generic" then
        addSquares(RaidBingoCatalog.raid_generic)
    end
    if #pool < 24 then
        print("This deck does not contain enough unique squares to make a full card.")
        return self:GetDefaultCard()
    end

    self:ShuffleTable(pool)
    local newCard = { squares = {}, gridSize = 5, centerSquareIndex = 13 }
    local nextSquare = 1
    for i = 1, 25 do
        if i == 13 then
            newCard.squares[i] = "Free Space"
        else
            newCard.squares[i] = pool[nextSquare]
            nextSquare = nextSquare + 1
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
    local frame = CreateFrame("Frame", "RaidBingoFrame", UIParent, "BackdropTemplate");
    frame:SetSize(400, 500);
    frame:SetPoint("CENTER");
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 11, top = 11, bottom = 11 }
        });
        if frame.SetBackdropColor then
            frame:SetBackdropColor(0, 0, 0, 0.8);
        end
    end

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

-- Keep the randomized board stable across reloads so saved marks still refer to the same squares.
function addon:GenerateAndDisplayCard(forceNew)
    RaidBingoDB = RaidBingoDB or {}
    local saved = RaidBingoDB.cardSquares
    if not forceNew and RaidBingoDB.selectedDeck == currentDeck and type(saved) == "table" and #saved == 25 then
        cardData = { squares = saved, gridSize = 5, centerSquareIndex = 13 }
    else
        cardData = self:GenerateCardFromCatalog(currentDeck)
        RaidBingoDB.cardSquares = cardData.squares
        RaidBingoDB.selectedDeck = currentDeck
        RaidBingoDB.playerMarks = {}
        RaidBingoDB.bingoAnnounced = false
        playerMarks = RaidBingoDB.playerMarks
    end
    self.currentCard = cardData
    self.bingoAnnounced = RaidBingoDB.bingoAnnounced or false
    if self.mainFrame then self:UpdateCard() end
end

function addon:GetCurrentDeck()
    return currentDeck
end

function addon:SelectDeck(deckName)
    if not RaidBingoCatalog or not RaidBingoCatalog[deckName] then return false end
    currentDeck = deckName
    RaidBingoDB.selectedDeck = deckName
    RaidBingoDB.playerMarks = {}
    RaidBingoDB.cardSquares = nil
    RaidBingoDB.bingoAnnounced = false
    playerMarks = RaidBingoDB.playerMarks
    self.bingoAnnounced = false
    self:GenerateAndDisplayCard(true)
    return true
end

function addon:NewCard()
    RaidBingoDB.playerMarks = {}
    RaidBingoDB.cardSquares = nil
    RaidBingoDB.bingoAnnounced = false
    playerMarks = RaidBingoDB.playerMarks
    self.bingoAnnounced = false
    self:GenerateAndDisplayCard(true)
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

-- Refresh all 25 cells through the UI module.
function addon:UpdateUI()
    if self.UpdateCard then self:UpdateCard() end
end

-- Slash commands remain available alongside the visible deck dropdown.
function addon:HandleCommand(msg)
    msg = string.lower((msg or ""):match("^%s*(.-)%s*$"))
    local decks = {
        bt = "black_temple", hyjal = "mount_hyjal", ssc = "ssc",
        tk = "tempest_keep", za = "zul_aman", generic = "raid_generic"
    }
    if msg == "" or msg == "toggle" then
        self:ToggleUI()
    elseif msg == "reset" then
        RaidBingoDB.playerMarks = {}
        RaidBingoDB.bingoAnnounced = false
        playerMarks = RaidBingoDB.playerMarks
        self.bingoAnnounced = false
        self:UpdateUI()
        print("Raid Bingo marks reset.")
    elseif msg == "new" then
        self:NewCard()
    elseif decks[msg] then
        self:SelectDeck(decks[msg])
        print("Switched to " .. msg .. " bingo deck.")
    else
        print("Raid Bingo commands: /rb toggle, /rb new, /rb reset, /rb bt, /rb hyjal, /rb ssc, /rb tk, /rb za, /rb generic")
    end
end

-- Register slash command
SLASH_RAIDBINGO1 = "/rb";
SlashCmdList["RAIDBINGO"] = function(msg)
    addon:HandleCommand(msg);
end;

-- The addon namespace is a table, not a Frame. Use one real frame for initialization.
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, _, loadedAddon)
    if loadedAddon == addonName then addon:OnEnable() end
end)

SLASH_RAIDBINGO2 = "/raidbingo"

-- Export the addon for use by other modules
RaidBingoAddon = addon;
