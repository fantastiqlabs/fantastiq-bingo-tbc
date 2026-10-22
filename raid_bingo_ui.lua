-- Raid Bingo Addon UI Component for World of Warcraft: The Burning Crusade (1.12.1)
-- This file handles all UI related functionality

-- Create the addon namespace
local addonName, addon = ...

-- Create and manage the main UI frame
function addon:CreateUI()
    -- Create the main frame
    local frame = CreateFrame("Frame", "RaidBingoFrame", UIParent)
    frame:SetSize(400, 500)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 11, top = 11, bottom = 11 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)

    -- Make the frame movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Add a title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Raid Bingo Card")

    -- Create the grid of buttons (5x5)
    self.gridButtons = {}
    for i = 1, 25 do
        local button = CreateFrame("Button", "RaidBingoButton" .. i, frame, "UIPanelButtonTemplate")
        button:SetSize(70, 40)

        -- Position buttons in a grid
        local row = math.floor((i - 1) / 5)
        local col = (i - 1) % 5

        if i == 13 then
            -- Center square is "Free Space"
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", 20 + col * 80, -60 - row * 50)
        else
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", 20 + col * 80, -60 - row * 50)
        end

        -- Set up the button click handler
        button:SetScript("OnClick", function()
            self:ToggleMark(i)
        end)

        -- Store reference to button for later updates
        self.gridButtons[i] = button

        -- Create font string for button text
        local buttonText = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        buttonText:SetPoint("CENTER", 0, 0)
        buttonText:SetJustifyH("CENTER")
        buttonText:SetText("")

        -- Store reference to the text
        button.text = buttonText

        -- Set initial state for the button (not marked)
        self:UpdateButtonState(i, false)
    end

    -- Add a close button
    local closeButton = CreateFrame("Button", "RaidBingoCloseButton", frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Store reference to the main frame
    self.mainFrame = frame

    -- Initially hide the frame
    frame:Hide()
end

-- Update button state (marked or not marked)
function addon:UpdateButtonState(buttonIndex, isMarked)
    local button = self.gridButtons[buttonIndex]
    if not button then return end

    -- Get the card data to determine text and marking status
    local cardData = self:GetCardData()

    -- Update button appearance based on mark state
    if isMarked then
        button:SetBackdropColor(0, 1, 0, 0.3) -- Green background for marked squares
        button.text:SetTextColor(0, 0, 0, 1)   -- Black text for marked squares
    else
        button:SetBackdropColor(0, 0, 0, 0.5) -- Dark background for unmarked squares
        button.text:SetTextColor(1, 1, 1, 1)   -- White text for unmarked squares
    end

    -- Update the text on the button
    if cardData and cardData.squares then
        local squareText = cardData.squares[buttonIndex]
        if not squareText then
            squareText = ""
        end

        -- Special handling for "Free Space"
        if squareText == "Free Space" then
            button.text:SetText("FREE")
        else
            button.text:SetText(squareText)
        end
    end

    -- Set the button's tooltip
    local tooltipText = cardData and cardData.squares[buttonIndex] or ""
    if tooltipText ~= "" then
        button:SetScript("OnEnter", function()
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltipText)
            GameTooltip:Show()
        end)

        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
end

-- Toggle mark state for a square
function addon:ToggleMark(squareIndex)
    -- Get the current player's marks
    local playerMarks = self:GetPlayerMarks()

    -- Check if this square is already marked by this player
    local isMarked = false
    if playerMarks[squareIndex] then
        isMarked = playerMarks[squareIndex]
    end

    -- Toggle the mark state
    playerMarks[squareIndex] = not isMarked

    -- Save the updated marks
    self:SavePlayerMarks()

    -- Update UI to reflect new state
    self:UpdateButtonState(squareIndex, not isMarked)

    -- Check for completed lines (horizontal or vertical)
    if not isMarked then
        self:CheckForCompletedLines()
    end
end

-- Show the main frame
function addon:ShowUI()
    if self.mainFrame then
        self.mainFrame:Show()

        -- Update all buttons to show current marks
        local playerMarks = self:GetPlayerMarks()
        for i = 1, 25 do
            self:UpdateButtonState(i, playerMarks[i] or false)
        end
    end
end

-- Hide the main frame
function addon:HideUI()
    if self.mainFrame then
        self.mainFrame:Hide()
    end
end

-- Check for completed lines (horizontal and vertical only)
function addon:CheckForCompletedLines()
    local playerMarks = self:GetPlayerMarks()

    -- Check horizontal lines (5 rows)
    for row = 0, 4 do
        local isRowComplete = true
        for col = 0, 4 do
            local index = row * 5 + col + 1
            if not playerMarks[index] then
                isRowComplete = false
                break
            end
        end

        -- If a row is complete, show a message (this would be expanded in full implementation)
        if isRowComplete then
            print("|cFFFF0000Line completed!|r")
        end
    end

    -- Check vertical lines (5 columns)
    for col = 0, 4 do
        local isColComplete = true
        for row = 0, 4 do
            local index = row * 5 + col + 1
            if not playerMarks[index] then
                isColComplete = false
                break
            end
        end

        -- If a column is complete, show a message (this would be expanded in full implementation)
        if isColComplete then
            print("|cFFFF0000Line completed!|r")
        end
    end

    -- Note: Diagonal lines are not implemented for MVP as per requirements
end

-- Get the current player's marks from saved variables
function addon:GetPlayerMarks()
    if not RaidBingoDB or not RaidBingoDB.playerMarks then
        return {}
    end
    return RaidBingoDB.playerMarks
end

-- Save player marks to saved variables
function addon:SavePlayerMarks()
    if not RaidBingoDB then
        RaidBingoDB = {}
    end

    if not RaidBingoDB.playerMarks then
        RaidBingoDB.playerMarks = {}
    end

    -- This function is called from ToggleMark, so we don't need to do anything here
    -- The marks are updated directly in the table and will be saved automatically by WoW's system
end

-- Get card data (from the addon's cardData)
function addon:GetCardData()
    -- This will be set by the main addon when a card is generated
    if not cardData then
        -- Return default card if no cardData is available yet
        return self:GetDefaultCard()
    end
    return cardData or {}
end

-- Update the card display with current data
function addon:UpdateCard()
    if not self.mainFrame then return end
    
    local cardData = self:GetCardData()
    
    -- Update all buttons in the grid
    for i = 1, 25 do
        local button = self.gridButtons[i]
        if button then
            -- Get player marks from addon
            local playerMarks = self:GetPlayerMarks()
            local isMarked = playerMarks[i] or false
            
            -- Update button appearance based on mark state
            if isMarked then
                button:SetBackdropColor(0, 1, 0, 0.3) -- Green background for marked squares
                button.text:SetTextColor(0, 0, 0, 1)   -- Black text for marked squares
            else
                button:SetBackdropColor(0, 0, 0, 0.5) -- Dark background for unmarked squares
                button.text:SetTextColor(1, 1, 1, 1)   -- White text for unmarked squares
            end
            
            -- Update the text on the button
            if cardData and cardData.squares then
                local squareText = cardData.squares[i]
                if not squareText then
                    squareText = ""
                end
                
                -- Special handling for center square
                if i == 13 then  -- Center square index (1-based)
                    button.text:SetText(squareText)
                else
                    button.text:SetText(squareText)
                end
            end
        end
    end
end

-- Function to get the default card for fallback
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
