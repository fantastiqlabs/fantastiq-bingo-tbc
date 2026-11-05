local addonName, addon = ...

local levelBands = {
    { min = 1, max = 10 },
    { min = 11, max = 20 },
    { min = 21, max = 30 },
    { min = 31, max = 40 },
    { min = 41, max = 50 },
    { min = 51, max = 60 },
}
local families = {
    { id = "all", label = "Adventure" },
    { id = "dungeon", label = "Dungeons" },
    { id = "quest_story", label = "Quest + Story" },
    { id = "moments", label = "Memories" },
}
local cellButtons = {}
local selectedIndex = 1
local seedCounter = 0
local seedHasFocus = false
local currentBoard
local selection = { mode = "solo", family = "all", bandIndex = 1 }

local panel = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
panel:SetSize(720, 610)
panel:SetPoint("CENTER")
panel:SetFrameStrata("DIALOG")
panel:SetClampedToScreen(true)
panel:SetMovable(true)
panel:EnableMouse(true)
panel:RegisterForDrag("LeftButton")
panel:SetScript("OnDragStart", panel.StartMoving)
panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
panel:EnableKeyboard(true)
panel:SetPropagateKeyboardInput(true)
panel:Hide()

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", panel, "TOP", 0, -9)
title:SetText("Fantastiq Bingo - Forever")

local function createLabel(text, point, relativeTo, relativePoint, x, y, font)
    local label = panel:CreateFontString(nil, "ARTWORK", font or "GameFontNormal")
    label:SetPoint(point, relativeTo, relativePoint, x, y)
    label:SetText(text)
    return label
end

local function createButton(text, x, y, width, height, onClick)
    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetSize(width, height)
    button:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local modeButton = createButton("Mode: Solo", 18, -34, 112, 26)
local familyButton = createButton("Family: Adventure", 136, -34, 150, 26)
local levelButton = createButton("Levels 1-10", 292, -34, 128, 26)
createLabel("Share seed", "TOPLEFT", panel, "TOPLEFT", 420, -41)
local seedInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
seedInput:SetSize(98, 26)
seedInput:SetPoint("TOPLEFT", panel, "TOPLEFT", 478, -35)
seedInput:SetAutoFocus(false)
seedInput:SetNumeric(true)
seedInput:SetMaxLetters(10)
seedInput:SetScript("OnEditFocusGained", function() seedHasFocus = true end)
seedInput:SetScript("OnEditFocusLost", function() seedHasFocus = false end)

local status = createLabel("Choose a board and mark squares as you go.", "TOPLEFT", panel, "TOPLEFT", 20, -72)
status:SetWidth(360)
status:SetJustifyH("LEFT")
local progress = createLabel("Marked 0/24  |  Lines 0  |  Seed -", "TOPRIGHT", panel, "TOPRIGHT", -20, -72)
local help = createLabel("Arrow keys move  |  Space/Enter mark  |  Esc closes  |  Share seed for same squares", "BOTTOMLEFT", panel, "BOTTOMLEFT", 20, 22, "GameFontDisableSmall")
help:SetWidth(680)
help:SetJustifyH("CENTER")

local function selectedFamily()
    for index, family in ipairs(families) do
        if family.id == selection.family then return family, index end
    end
    return families[1], 1
end

local function getCompletedLines(board)
    local completed = 0
    local function lineIsComplete(indices)
        for _, index in ipairs(indices) do
            if not board.cells[index].mark then return false end
        end
        return true
    end
    for row = 0, 4 do
        local indices = {}
        for col = 1, 5 do indices[#indices + 1] = row * 5 + col end
        if lineIsComplete(indices) then completed = completed + 1 end
    end
    for col = 1, 5 do
        local indices = {}
        for row = 0, 4 do indices[#indices + 1] = row * 5 + col end
        if lineIsComplete(indices) then completed = completed + 1 end
    end
    if lineIsComplete({ 1, 7, 13, 19, 25 }) then completed = completed + 1 end
    if lineIsComplete({ 5, 9, 13, 17, 21 }) then completed = completed + 1 end
    return completed
end

local function refreshBoard()
    if not currentBoard then return end
    local marked = 0
    for index, cell in ipairs(currentBoard.cells) do
        local button = cellButtons[index]
        if cell.mark and not cell.free then marked = marked + 1 end
        local state = cell.free and "FREE" or cell.mark and (cell.mark.source == "manual" and "M" or "A") or ""
        local focus = selectedIndex == index and "> " or ""
        button.label:SetText(focus .. state .. "\n" .. cell.text)
        if cell.mark then
            button.label:SetTextColor(0.45, 1, 0.65)
        elseif selectedIndex == index then
            button.label:SetTextColor(1, 0.82, 0.32)
        else
            button.label:SetTextColor(0.93, 0.93, 0.93)
        end
    end
    progress:SetText(("Marked %d/24  |  Lines %d  |  Seed %d"):format(
        marked, getCompletedLines(currentBoard), currentBoard.seed
    ))
    modeButton:SetText("Mode: " .. (selection.mode == "solo" and "Solo" or "Group"))
    familyButton:SetText("Family: " .. selectedFamily().label)
    local band = levelBands[selection.bandIndex]
    levelButton:SetText(("Levels %d-%d"):format(band.min, band.max))
    seedInput:SetText(tostring(currentBoard.seed))
end

local function openSelectedBoard(seed)
    local band = levelBands[selection.bandIndex]
    local board, err = addon.OpenBoard(selection.mode, band.min, band.max, seed, selection.family)
    if not board then
        if currentBoard then
            selection.mode = currentBoard.mode
            selection.family = currentBoard.family or "all"
            for index, currentBand in ipairs(levelBands) do
                if currentBand.min == currentBoard.minLevel and currentBand.max == currentBoard.maxLevel then
                    selection.bandIndex = index
                end
            end
            refreshBoard()
        end
        status:SetText(err)
        return false
    end
    currentBoard = board
    status:SetText("Manual marks stay local. Share the seed with friends.")
    refreshBoard()
    return true
end

seedInput:SetScript("OnEnterPressed", function(self)
    local seed = tonumber(self:GetText())
    if seed then openSelectedBoard(seed) else status:SetText("Enter a numeric seed or choose New seed.") end
    self:ClearFocus()
end)

local function nextSeed()
    seedCounter = seedCounter + 1
    local clock = type(GetTime) == "function" and math.floor(GetTime() * 1000) or (type(time) == "function" and time() or 1)
    return clock + seedCounter
end

local function toggleSquare(index)
    if not currentBoard or index == 13 then return end
    if currentBoard.cells[index].mark then
        addon.UnmarkSquare(currentBoard, index)
    else
        addon.MarkSquare(currentBoard, index, "manual")
    end
    refreshBoard()
end

for index = 1, 25 do
    local cellIndex = index
    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetSize(132, 78)
    local row, col = math.floor((index - 1) / 5), (index - 1) % 5
    button:SetPoint("TOPLEFT", panel, "TOPLEFT", 18 + col * 136, -112 - row * 82)
    button:SetText("")
    button:RegisterForClicks("LeftButtonUp")
    button.label = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    button.label:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -4)
    button.label:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 4)
    button.label:SetJustifyH("CENTER")
    button.label:SetJustifyV("MIDDLE")
    button.label:SetWordWrap(true)
    button:SetScript("OnClick", function() selectedIndex = cellIndex; toggleSquare(cellIndex) end)
    cellButtons[cellIndex] = button
end

modeButton:SetScript("OnClick", function()
    if selection.family == "dungeon" then
        status:SetText("Dungeon boards use Group mode.")
        return
    end
    selection.mode = selection.mode == "solo" and "group" or "solo"
    openSelectedBoard(seedInput:GetText())
end)
familyButton:SetScript("OnClick", function()
    local _, index = selectedFamily()
    selection.family = families[index % #families + 1].id
    if selection.family == "dungeon" then selection.mode = "group" end
    openSelectedBoard(seedInput:GetText())
end)
levelButton:SetScript("OnClick", function()
    selection.bandIndex = selection.bandIndex % #levelBands + 1
    openSelectedBoard(seedInput:GetText())
end)

createButton("New seed", 590, -35, 108, 26, function() openSelectedBoard(nextSeed()) end)
panel:SetScript("OnKeyDown", function(self, key)
    if InCombatLockdown and InCombatLockdown() then return end
    if seedHasFocus then self:SetPropagateKeyboardInput(false); return end
    local nextIndex = selectedIndex
    if key == "LEFT" and (selectedIndex - 1) % 5 > 0 then nextIndex = selectedIndex - 1
    elseif key == "RIGHT" and selectedIndex % 5 > 0 then nextIndex = selectedIndex + 1
    elseif key == "UP" and selectedIndex > 5 then nextIndex = selectedIndex - 5
    elseif key == "DOWN" and selectedIndex <= 20 then nextIndex = selectedIndex + 5
    elseif key == "SPACE" or key == " " or key == "ENTER" or key == "RETURN" then
        toggleSquare(selectedIndex)
        self:SetPropagateKeyboardInput(false)
        return
    elseif key == "ESCAPE" then
        self:Hide()
        self:SetPropagateKeyboardInput(false)
        return
    else
        self:SetPropagateKeyboardInput(true)
        return
    end
    selectedIndex = nextIndex
    refreshBoard()
    self:SetPropagateKeyboardInput(false)
end)

function addon.ShowBoardUI(board)
    if board then
        currentBoard = board
        selection.mode = board.mode
        selection.family = board.family or "all"
        for index, band in ipairs(levelBands) do
            if band.min == board.minLevel and band.max == board.maxLevel then selection.bandIndex = index end
        end
    elseif not currentBoard then
        local db = addon.db or addon.InitializeSavedVariables()
        currentBoard = db.currentBoardId and addon.LoadBoard(db.currentBoardId)
        if not currentBoard then openSelectedBoard(nextSeed()) end
    end
    if currentBoard then refreshBoard() end
    panel:Show()
end

function addon.ToggleBoardUI()
    if panel:IsShown() then panel:Hide() else addon.ShowBoardUI() end
end
