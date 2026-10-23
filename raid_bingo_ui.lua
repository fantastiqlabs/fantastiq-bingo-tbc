-- Raid Bingo Addon UI Component for World of Warcraft: The Burning Crusade Anniversary Edition (Interface 20506)
-- This file handles all UI related functionality

-- Create the addon namespace
local addonName, addon = ...

-- Marked cells use an explicit green texture rather than tinting the button's
-- backdrop, whose appearance varies between client button templates.
local function SetButtonMarked(button, isMarked)
    if button.markOverlay then
        if isMarked then
            button.markOverlay:Show()
        else
            button.markOverlay:Hide()
        end
    end

    if button.text then
        if isMarked then
            button.text:SetTextColor(0, 0, 0, 1)
        else
            button.text:SetTextColor(1, 1, 1, 1)
        end
    end
end

local labelFont, _, labelFontFlags = GameFontNormal:GetFont()
local function SetButtonLabel(button, label)
    local text = button.text
    text:SetText(label)
    if not labelFont then return end

    -- Start comfortably readable, then step down until wrapped text fits the
    -- cell's available height. The minimum prevents tiny, unusable labels.
    for fontSize = 12, 7, -1 do
        text:SetFont(labelFont, fontSize, labelFontFlags)
        if text:GetStringHeight() <= text:GetHeight() then
            break
        end
    end
end

-- Create and manage the main UI frame
function addon:CreateUI()
    -- Create the main frame
    local frame = CreateFrame("Frame", "RaidBingoFrame", UIParent, "BackdropTemplate")
    frame:SetSize(440, 500)
    frame:SetPoint("CENTER")
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 11, top = 11, bottom = 11 }
        })
        if frame.SetBackdropColor then
            frame:SetBackdropColor(0, 0, 0, 0.8)
        end
    end

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

    local deckSelector = CreateFrame("Frame", "RaidBingoDeckSelector", frame, "UIDropDownMenuTemplate")
    deckSelector:SetPoint("TOP", frame, "TOP", 0, -28)
    UIDropDownMenu_SetWidth(deckSelector, 170)
    local deckOptions = {
        { label = "Raid Generic", value = "raid_generic" },
        { label = "Black Temple", value = "black_temple" },
        { label = "Mount Hyjal", value = "mount_hyjal" },
        { label = "Serpentshrine Cavern", value = "ssc" },
        { label = "Tempest Keep", value = "tempest_keep" },
        { label = "Zul'Aman", value = "zul_aman" },
    }
    UIDropDownMenu_Initialize(deckSelector, function(dropdown, level)
        for _, option in ipairs(deckOptions) do
            local deckValue, deckLabel = option.value, option.label
            local info = UIDropDownMenu_CreateInfo()
            info.text = deckLabel
            info.value = deckValue
            info.func = function()
                addon:SelectDeck(deckValue)
                UIDropDownMenu_SetSelectedValue(deckSelector, deckValue)
                UIDropDownMenu_SetText(deckSelector, deckLabel)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    local selectedDeck = self:GetCurrentDeck()
    for _, option in ipairs(deckOptions) do
        if option.value == selectedDeck then
            UIDropDownMenu_SetSelectedValue(deckSelector, option.value)
            UIDropDownMenu_SetText(deckSelector, option.label)
            break
        end
    end

    -- Create the grid of buttons (5x5)
    self.gridButtons = {}
    for i = 1, 25 do
        local buttonIndex = i
        local button = CreateFrame("Button", "RaidBingoButton" .. buttonIndex, frame, "UIPanelButtonTemplate")
        button:SetSize(76, 62)

        -- Position buttons in a grid
        local row = math.floor((i - 1) / 5)
        local col = (i - 1) % 5

        button:SetPoint("TOPLEFT", frame, "TOPLEFT", 20 + col * 80, -75 - row * 75)

        local markOverlay = button:CreateTexture(nil, "OVERLAY")
        markOverlay:SetAllPoints(button)
        markOverlay:SetColorTexture(0, 0.85, 0.1, 0.9)
        markOverlay:Hide()
        button.markOverlay = markOverlay

        -- Set up the button click handler
        button:SetScript("OnClick", function()
            self:ToggleMark(buttonIndex)
        end)

        -- Store reference to button for later updates
        self.gridButtons[i] = button

        -- Create font string for button text
        local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        buttonText:SetPoint("CENTER", 0, 0)
        buttonText:SetSize(68, 54)
        buttonText:SetDrawLayer("OVERLAY", 1)
        buttonText:SetJustifyH("CENTER")
        buttonText:SetWordWrap(true)
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

    -- Initially hide the frame, then populate it with the saved or selected deck.
    frame:Hide()
    self:GenerateAndDisplayCard()
end

-- Update button state (marked or not marked)
function addon:UpdateButtonState(buttonIndex, isMarked)
    local button = self.gridButtons[buttonIndex]
    if not button then return end

    -- Get the card data to determine text and marking status
    local cardData = self:GetCardData()

    SetButtonMarked(button, isMarked)

    -- Update the text on the button
    if cardData and cardData.squares then
        local square = cardData.squares[buttonIndex]
        local squareText = type(square) == "table" and square.text or square or ""
        SetButtonLabel(button, squareText == "Free Space" and "FREE" or squareText)
    end

    -- Set the button's tooltip
    local square = cardData and cardData.squares[buttonIndex]
    local tooltipText = type(square) == "table" and square.text or square or ""
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

-- Clicking a square toggles a private saved mark. The free center is automatic.
function addon:ToggleMark(squareIndex)
    if squareIndex == 13 then return end
    local marks = self:GetPlayerMarks()
    marks[squareIndex] = not marks[squareIndex]
    self:SavePlayerMarks()
    self:UpdateCard()
    if marks[squareIndex] then self:CheckForCompletedLines() end
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

-- Horizontal/vertical lines are supported in this MVP; each card announces bingo once.
function addon:CheckForCompletedLines()
    if self.bingoAnnounced then return end
    local marks = self:GetPlayerMarks()
    local function marked(index) return index == 13 or marks[index] == true end
    local complete = false
    for row = 0, 4 do
        local full = true
        for col = 0, 4 do if not marked(row * 5 + col + 1) then full = false; break end end
        if full then complete = true; break end
    end
    if not complete then
        for col = 0, 4 do
            local full = true
            for row = 0, 4 do if not marked(row * 5 + col + 1) then full = false; break end end
            if full then complete = true; break end
        end
    end
    if complete then
        local quotes = {
            "The loot council totally saw that.",
            "Roll need on the confetti!",
            "Even LeChuck couldn't sink that card!",
            "A three-headed monkey approves!",
            "Please remain calm; the card is on fire.",
        }
        self.bingoAnnounced = true
        RaidBingoDB.bingoAnnounced = true
        SendChatMessage("BINGO!!!!!!!!! " .. quotes[math.random(#quotes)], "YELL")
    end
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
    return self.currentCard or self:GetDefaultCard()
end

-- Refresh the visible text and green mark state for the current board.
function addon:UpdateCard()
    if not self.mainFrame then return end
    local card = self:GetCardData()
    local marks = self:GetPlayerMarks()
    for i = 1, 25 do
        local button = self.gridButtons[i]
        local square = card.squares and card.squares[i]
        local text = type(square) == "table" and square.text or square or ""
        local tooltipText = i == 13 and "Free Space" or text
        if button then
            local marked = i == 13 or marks[i] == true
            SetButtonMarked(button, marked)
            SetButtonLabel(button, i == 13 and "FREE" or text)
            button:SetScript("OnEnter", function()
                GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipText)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function() GameTooltip:Hide() end)
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
