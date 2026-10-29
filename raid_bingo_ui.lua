-- Raid Bingo Addon UI Component for World of Warcraft: The Burning Crusade Anniversary Edition (Interface 20506)
-- This file handles all UI related functionality

-- Create the addon namespace
local addonName, addon = ...
local BOX_SCALE_PRESETS = { 80, 100, 120 }
local TEXT_SIZE_PRESETS = { 5, 6, 7, 8, 9, 10, 12, 14, 16, 18 }
local WINDOW_SCALE_PRESETS = { 25, 50, 75, 100, 125, 150 }

local CELL_UNMARKED_COLOR = { 0.84, 0.48, 0.48, 1 }
local CELL_MARKED_COLOR = { 0.58, 0.82, 0.58, 1 }

-- Color the button's backdrop directly. The fill and border are separate
-- regions, so changing state cannot paint across the frame.
local function SetButtonMarked(button, isMarked)
    if button.SetBackdropColor then
        local color = isMarked and CELL_MARKED_COLOR or CELL_UNMARKED_COLOR
        button:SetBackdropColor(color[1], color[2], color[3], color[4])
    end
end

local labelFont, _, labelFontFlags = GameFontNormal:GetFont()
local function SetButtonLabel(button, label)
    local text = button.text
    text:SetText(label)
    if not labelFont then return end

    -- Check measured height and estimated wrapped height so labels also fit
    -- on clients where FontString reports stale height after changing fonts.
    local preferredFontSize = RaidBingoDB and RaidBingoDB.textSize or 7
    for fontSize = preferredFontSize, 5, -1 do
        text:SetFont(labelFont, fontSize, labelFontFlags)
        local charactersPerLine = math.max(1, math.floor(text:GetWidth() / (fontSize * 0.58)))
        local estimatedLines = math.ceil(#label / charactersPerLine)
        local estimatedHeight = estimatedLines * fontSize * 1.25
        if text:GetStringHeight() <= text:GetHeight() and estimatedHeight <= text:GetHeight() then
            break
        end
    end
end

function addon:SetBoxScale(percent)
    local valid = false
    for _, preset in ipairs(BOX_SCALE_PRESETS) do
        if preset == percent then valid = true; break end
    end
    if not valid then return false end

    RaidBingoDB = RaidBingoDB or {}
    RaidBingoDB.boxScale = percent
    if self.boxScaleSelector then
        UIDropDownMenu_SetSelectedValue(self.boxScaleSelector, percent)
        UIDropDownMenu_SetText(self.boxScaleSelector, "Boxes: " .. percent .. "%")
    end
    if self.mainFrame then
        self:UpdateGridLayout()
        self:UpdateCard()
    end
    return true
end

function addon:SetTextSize(pointSize)
    local valid = false
    for _, preset in ipairs(TEXT_SIZE_PRESETS) do
        if preset == pointSize then valid = true; break end
    end
    if not valid then return false end

    RaidBingoDB = RaidBingoDB or {}
    RaidBingoDB.textSize = pointSize
    if self.textSizeSelector then
        UIDropDownMenu_SetSelectedValue(self.textSizeSelector, pointSize)
        UIDropDownMenu_SetText(self.textSizeSelector, "Text: " .. pointSize .. " pt")
    end
    if self.mainFrame then self:UpdateCard() end
    return true
end

function addon:SetWindowScale(percent)
    local valid = false
    for _, preset in ipairs(WINDOW_SCALE_PRESETS) do
        if preset == percent then valid = true; break end
    end
    if not valid then return false end

    RaidBingoDB = RaidBingoDB or {}
    RaidBingoDB.windowScale = percent
    if self.windowScaleSelector then
        UIDropDownMenu_SetSelectedValue(self.windowScaleSelector, percent)
        UIDropDownMenu_SetText(self.windowScaleSelector, "Window: " .. percent .. "%")
    end
    if self.mainFrame then self.mainFrame:SetScale(percent / 100) end
    return true
end

function addon:UpdateGridLayout()
    if not self.mainFrame or not self.gridButtons then return end
    local scale = (RaidBingoDB and RaidBingoDB.boxScale or 100) / 100
    local buttonWidth, buttonHeight = 100 * scale, 82 * scale
    local gapX, gapY = 10 * scale, 8 * scale
    local gridWidth = 5 * buttonWidth + 4 * gapX
    local gridHeight = 5 * buttonHeight + 4 * gapY
    -- Keep enough width for the three selectors while trimming the empty
    -- margins around the grid. Height follows the chosen box size directly.
    local frameWidth = math.max(620, gridWidth + 60)
    local frameHeight = gridHeight + 190
    self.mainFrame:SetSize(frameWidth, frameHeight)

    local startX = (frameWidth - gridWidth) / 2
    local topOffset = 120
    for index, button in ipairs(self.gridButtons) do
        local row = math.floor((index - 1) / 5)
        local col = (index - 1) % 5
        button:SetSize(buttonWidth, buttonHeight)
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", startX + col * (buttonWidth + gapX), -topOffset - row * (buttonHeight + gapY))

        button.text:ClearAllPoints()
        button.text:SetPoint("CENTER", button, "CENTER")
        button.text:SetSize(buttonWidth - 8 * scale, buttonHeight - 8 * scale)
    end
end

local function InitializeValueDropdown(dropdown, options, labelPrefix, unit, onSelect)
    UIDropDownMenu_SetWidth(dropdown, 105)
    UIDropDownMenu_Initialize(dropdown, function(_, level)
        for _, value in ipairs(options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = labelPrefix .. value .. unit
            info.value = value
            info.func = function()
                onSelect(value)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
end

-- Create and manage the main UI frame
function addon:CreateUI()
    -- Create the main frame
    local frame = CreateFrame("Frame", "RaidBingoFrame", UIParent, "BackdropTemplate")
    frame:SetSize(620, 650)
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
    title:SetText("Fantastiq Bingo TBC")

    local deckSelector = CreateFrame("Frame", "RaidBingoDeckSelector", frame, "UIDropDownMenuTemplate")
    deckSelector:SetPoint("TOP", frame, "TOP", 0, -29)
    UIDropDownMenu_SetWidth(deckSelector, 170)
    local deckOptions = {
        { label = "Raid Generic", value = "raid_generic" },
        { label = "Black Temple", value = "black_temple" },
        { label = "Mount Hyjal", value = "mount_hyjal" },
        { label = "Serpentshrine Cavern", value = "ssc" },
        { label = "Tempest Keep", value = "tempest_keep" },
        { label = "Zul'Aman", value = "zul_aman" },
    }
    for _, option in ipairs(addon:GetAutoDeckOptions()) do
        table.insert(deckOptions, option)
    end
    UIDropDownMenu_Initialize(deckSelector, function(dropdown, level)
        for _, option in ipairs(deckOptions) do
            local deckValue, deckLabel = option.value, option.label
            local info = UIDropDownMenu_CreateInfo()
            info.text = deckLabel
            info.value = deckValue
            if option.raid then
                local count, available, minimum = addon:GetAutoDeckStatus(deckValue)
                info.disabled = not available
                if not available then
                    info.text = string.format("%s (unavailable: %d/%d)", deckLabel, count, minimum)
                    info.tooltipTitle = deckLabel .. " unavailable"
                    info.tooltipText = string.format("Needs %d unique supported event squares; this catalog has %d.", minimum, count)
                    info.tooltipOnButton = true
                end
            end
            info.func = function()
                if addon:SelectDeck(deckValue) then
                    UIDropDownMenu_SetSelectedValue(deckSelector, deckValue)
                    UIDropDownMenu_SetText(deckSelector, deckLabel)
                end
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

    local boxScaleSelector = CreateFrame("Frame", "RaidBingoBoxScaleSelector", frame, "UIDropDownMenuTemplate")
    boxScaleSelector:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -58)
    InitializeValueDropdown(boxScaleSelector, BOX_SCALE_PRESETS, "Boxes: ", "%", function(value)
        addon:SetBoxScale(value)
    end)
    self.boxScaleSelector = boxScaleSelector

    local textSizeSelector = CreateFrame("Frame", "RaidBingoTextSizeSelector", frame, "UIDropDownMenuTemplate")
    textSizeSelector:SetPoint("TOP", frame, "TOP", 0, -58)
    InitializeValueDropdown(textSizeSelector, TEXT_SIZE_PRESETS, "Text: ", " pt", function(value)
        addon:SetTextSize(value)
    end)
    self.textSizeSelector = textSizeSelector

    local windowScaleSelector = CreateFrame("Frame", "RaidBingoWindowScaleSelector", frame, "UIDropDownMenuTemplate")
    windowScaleSelector:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -58)
    InitializeValueDropdown(windowScaleSelector, WINDOW_SCALE_PRESETS, "Window: ", "%", function(value)
        addon:SetWindowScale(value)
    end)
    self.windowScaleSelector = windowScaleSelector

    local autoMark = CreateFrame("CheckButton", "RaidBingoAutoMarkCheckbox", frame, "UICheckButtonTemplate")
    autoMark:SetSize(24, 24)
    autoMark:SetPoint("TOPLEFT", frame, "TOP", -95, -88)
    local autoMarkLabel = autoMark:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    autoMarkLabel:SetPoint("LEFT", autoMark, "RIGHT", 1, 0)
    autoMarkLabel:SetSize(166, 24)
    autoMarkLabel:SetText("Automark based on events")
    autoMark:SetHitRectInsets(0, -166, 0, 0)
    autoMark:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_TOP")
        GameTooltip:SetText("Match raid events to this card")
        GameTooltip:AddLine("Boss defeats, named mob kills, and matching mechanic hits can mark squares. Social moments stay manual.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    autoMark:SetScript("OnLeave", function() GameTooltip:Hide() end)
    autoMark:SetScript("OnClick", function(button)
        addon:SetAutoMarkEnabled(button:GetChecked())
    end)
    self.autoMarkCheckbox = autoMark

    -- Create the grid of buttons (5x5)
    self.gridButtons = {}
    for i = 1, 25 do
        local buttonIndex = i
        local button = CreateFrame("Button", "RaidBingoButton" .. buttonIndex, frame, "BackdropTemplate")
        button:SetSize(100, 82)
        button:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = false,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        button:SetBackdropBorderColor(1, 1, 1, 1)
        button:SetBackdropColor(CELL_UNMARKED_COLOR[1], CELL_UNMARKED_COLOR[2], CELL_UNMARKED_COLOR[3], CELL_UNMARKED_COLOR[4])

        -- Set up the button click handler
        button:SetScript("OnClick", function()
            self:ToggleMark(buttonIndex)
        end)

        -- Store reference to button for later updates
        self.gridButtons[i] = button

        -- Create font string for button text
        local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        buttonText:SetPoint("CENTER", 0, 0)
        buttonText:SetSize(92, 74)
        buttonText:SetDrawLayer("OVERLAY", 1)
        buttonText:SetJustifyH("CENTER")
        buttonText:SetJustifyV("MIDDLE")
        buttonText:SetTextColor(0.12, 0.12, 0.12, 1)
        buttonText:SetWordWrap(true)
        if buttonText.SetNonSpaceWrap then buttonText:SetNonSpaceWrap(true) end
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
    RaidBingoDB = RaidBingoDB or {}
    self:SetBoxScale(RaidBingoDB.boxScale or 100)
    self:SetTextSize(RaidBingoDB.textSize or 7)
    self:SetWindowScale(RaidBingoDB.windowScale or 100)
    autoMark:SetChecked(RaidBingoDB.autoMarkEvents == true)
    self:UpdateGridLayout()

    local footer = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    footer:SetPoint("BOTTOM", frame, "BOTTOM", 0, 16)
    footer:SetText("Click squares to mark   |   Green marks can also follow matched combat events")

    -- Initially hide the frame, then populate it with the saved or selected deck.
    frame:Hide()
    self:GenerateAndDisplayCard()
end

-- Create a standard minimap launcher that toggles the bingo window.
function addon:CreateMinimapButton()
    if self.minimapButton or not Minimap then return end
    local button = CreateFrame("Button", "RaidBingoMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    button:SetMovable(true)
    button:RegisterForClicks("LeftButtonUp")
    button:SetScript("OnClick", function() addon:ToggleUI() end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Fantastiq Bingo TBC")
        GameTooltip:AddLine("Click to show or hide your card", 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")
    button.icon = icon
    self.minimapButton = button
end

-- Update button state (marked or not marked)
function addon:UpdateButtonState(buttonIndex, isMarked)
    local button = self.gridButtons[buttonIndex]
    if not button then return end

    -- Get the card data to determine text and marking status
    local cardData = self:GetCardData()

    local freeSpace = self:IsFreeSpace(buttonIndex)
    SetButtonMarked(button, isMarked or freeSpace)

    -- Update the text on the button
    if cardData and cardData.squares then
        local square = cardData.squares[buttonIndex]
        local squareText = type(square) == "table" and square.text or square or ""
        SetButtonLabel(button, freeSpace and "FREE" or squareText)
    end

    -- Set the button's tooltip
    local square = cardData and cardData.squares[buttonIndex]
    local tooltipText = freeSpace and "Free Space" or (type(square) == "table" and square.text or square or "")
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

-- Clicking a square toggles a private saved mark. Free squares are automatic.
function addon:ToggleMark(squareIndex)
    if self:IsFreeSpace(squareIndex) then return end
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
            self:UpdateButtonState(i, playerMarks[i] or self:IsFreeSpace(i))
        end
    end
end

-- Hide the main frame
function addon:HideUI()
    if self.mainFrame then
        self.mainFrame:Hide()
    end
end

-- Announce each new bingo milestone once per card, even when earlier lines already won.
function addon:CheckForCompletedLines()
    local marks = self:GetPlayerMarks()
    local function marked(index) return self:IsFreeSpace(index) or marks[index] == true end
    local completedLines = 0
    for row = 0, 4 do
        local full = true
        for col = 0, 4 do if not marked(row * 5 + col + 1) then full = false; break end end
        if full then completedLines = completedLines + 1 end
    end
    for col = 0, 4 do
        local full = true
        for row = 0, 4 do if not marked(row * 5 + col + 1) then full = false; break end end
        if full then completedLines = completedLines + 1 end
    end
    local fullBoard = true
    for index = 1, 25 do
        if not marked(index) then fullBoard = false; break end
    end
    local milestone = fullBoard and 3 or completedLines >= 2 and 2 or completedLines >= 1 and 1 or 0
    RaidBingoDB = RaidBingoDB or {}
    local previous = tonumber(RaidBingoDB.bingoMilestone) or (RaidBingoDB.bingoAnnounced and 1 or 0)
    if milestone <= previous then return end

    local announcements = {
        [1] = "BINGO 1 ROW!",
        [2] = "BINGO TWO ROWS!",
        [3] = "BINGO FULL BOARD!",
    }
    local quotes = {
        "The loot council totally saw that.",
        "Roll need on the confetti!",
        "Even LeChuck couldn't sink that card!",
        "A three-headed monkey approves!",
        "Please remain calm; the card is on fire.",
        "Guybrush has already claimed the victory grog.",
        "Elaine is taking over the victory speech.",
        "LeChuck's ghost ship just sounded its foghorn.",
        "Murray approves, and that is deeply unsettling.",
        "Stan is selling a map to your winning square.",
        "The Voodoo Lady predicted this row over tea.",
        "Carla wants a rematch against the whole card.",
        "Meathook volunteered to paint the celebration banner.",
        "The Sword Master has no comeback for that row.",
        "Three parrots are squabbling over your prize.",
        "A treasure map now marks your bingo as X.",
        "The crew found treasure: one complete row.",
        "That yell carried farther than a cannonball.",
        "Somebody fetch grog; this card earned it.",
        "LeChuck has been temporarily removed from the scoreboard.",
        "The monkey has appointed itself loot master.",
        "Guybrush swears this was all part of his plan.",
        "The ship's crew is celebrating before checking the loot.",
        "A voodoo charm says to keep clicking.",
    }
    RaidBingoDB.bingoMilestone = milestone
    RaidBingoDB.bingoAnnounced = true
    self.bingoMilestone = milestone
    self.bingoAnnounced = true
    SendChatMessage(announcements[milestone] .. " " .. quotes[math.random(#quotes)], "YELL")
    DoEmote("LAUGH")
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
        local freeSpace = self:IsFreeSpace(i)
        local tooltipText = freeSpace and "Free Space" or text
        if button then
            local marked = freeSpace or marks[i] == true
            SetButtonMarked(button, marked)
            SetButtonLabel(button, freeSpace and "FREE" or text)
            button:SetScript("OnEnter", function()
                GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                GameTooltip:SetText(tooltipText)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
    end
end
