-- Raid Bingo Addon for World of Warcraft: The Burning Crusade (1.12.1)
-- Main addon file

-- Create the addon namespace
local addonName, addon = ...

-- Card data - this will be defined in raid_bingo_card.lua
local cardData = nil;

-- Player's marking state
local playerMarks = {};

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

-- Load card data from the card module
function addon:LoadCardData()
    -- This will be called after the card file is loaded
    if not raid_bingo_card then
        print("Error: Card data not found!");
        return false;
    end

    cardData = raid_bingo_card.GetCardData();
    return true;
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

-- Check for completed lines (horizontal, vertical, diagonal)
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

    -- Diagonal lines (2 diagonals)
    local diag1Complete = true;  -- Top-left to bottom-right
    for i = 0, 4 do
        local index = i * 5 + i + 1;
        if not playerMarks[index] then
            diag1Complete = false;
            break;
        end
    end
    if diag1Complete then
        table.insert(lines, "diag_1");
    end

    local diag2Complete = true;  -- Top-right to bottom-left
    for i = 0, 4 do
        local index = i * 5 + (4 - i) + 1;
        if not playerMarks[index] then
            diag2Complete = false;
            break;
        end
    end
    if diag2Complete then
        table.insert(lines, "diag_2");
    end

    return lines;
end

-- Update the UI to show current marks and completed lines
function addon:UpdateUI()
    -- This will be implemented in raid_bingo_ui.lua
    print("Updating UI...");
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
    else
        print("Available commands:");
        print("/rb toggle - Toggle the bingo card UI");
        print("/rb reset - Reset all your marks");
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
