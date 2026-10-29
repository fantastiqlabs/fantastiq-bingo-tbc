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
local eventFrame
local AUTO_DECK_MINIMUM = 22
local AUTO_DECKS = {
    { label = "Black Temple Auto", value = "auto_black_temple", raid = "black_temple" },
    { label = "Mount Hyjal Auto", value = "auto_mount_hyjal", raid = "mount_hyjal" },
    { label = "Serpentshrine Cavern Auto", value = "auto_ssc", raid = "ssc" },
    { label = "Tempest Keep Auto", value = "auto_tempest_keep", raid = "tempest_keep" },
    { label = "Zul'Aman Auto", value = "auto_zul_aman", raid = "zul_aman" },
}
local AUTO_DECK_RAIDS = {}
for _, option in ipairs(AUTO_DECKS) do AUTO_DECK_RAIDS[option.value] = option.raid end
local isAutoMarkableSquare

local function shareWinningLine(a, b, c)
    local rowA, colA = math.floor((a - 1) / 5), (a - 1) % 5
    local rowB, colB = math.floor((b - 1) / 5), (b - 1) % 5
    local rowC, colC = math.floor((c - 1) / 5), (c - 1) % 5
    return (rowA == rowB and rowB == rowC)
        or (colA == colB and colB == colC)
        or (rowA - colA == rowB - colB and rowB - colB == rowC - colC)
        or (rowA + colA == rowB + colB and rowB + colB == rowC + colC)
end

function addon:GenerateFreeSpacePositions()
    local positions = {}
    repeat
        positions = {}
        for index = 1, 25 do positions[index] = index end
        self:ShuffleTable(positions)
    until not shareWinningLine(positions[1], positions[2], positions[3])
    return { [positions[1]] = true, [positions[2]] = true, [positions[3]] = true }
end

function addon:ApplyRandomFreeSpaces(card)
    card.freeSpaces = self:GenerateFreeSpacePositions()
    for index = 1, 25 do
        if card.freeSpaces[index] then card.squares[index] = "Free Space" end
    end
    return card
end

local function collectUniqueSquares(source, seenIds, seenText, eligible)
    seenIds = seenIds or {}
    seenText = seenText or {}
    local squares = {}
    for _, square in ipairs(source or {}) do
        local textKey = square and square.text and string.lower(square.text)
        if square and square.id and textKey and not seenIds[square.id] and not seenText[textKey]
            and (not eligible or eligible(square)) then
            seenIds[square.id] = true
            seenText[textKey] = true
            table.insert(squares, square)
        end
    end
    return squares
end

-- Initialize saved state and create the interface once the addon files are loaded.
function addon:OnEnable()
    RaidBingoDB = RaidBingoDB or {}
    RaidBingoDB.playerMarks = RaidBingoDB.playerMarks or {}
    playerMarks = RaidBingoDB.playerMarks

    if RaidBingoCatalog and RaidBingoCatalog[RaidBingoDB.selectedDeck] then
        currentDeck = RaidBingoDB.selectedDeck
    elseif AUTO_DECK_RAIDS[RaidBingoDB.selectedDeck] then
        local count, available = self:GetAutoDeckStatus(RaidBingoDB.selectedDeck)
        if available then
            currentDeck = RaidBingoDB.selectedDeck
        else
            print(string.format("That Auto deck is unavailable: it has %d of %d required verified event squares. Switched to Raid Generic.", count, AUTO_DECK_MINIMUM))
            RaidBingoDB.selectedDeck = "raid_generic"
            currentDeck = "raid_generic"
        end
    end

    self:CreateUI()
    self:CreateMinimapButton()
    self:SetAutoMarkEnabled(RaidBingoDB.autoMarkEvents == true)
    print("|cFF00FF00Fantastiq Bingo TBC loaded. Marks are self-reported and private.|r")
end

-- Generate a no-duplicate card. Raid-specific decks mix a random 2–8 raid
-- squares with generic moments; the dedicated generic deck stays raid-neutral.
function addon:GenerateCardFromCatalog(deckName)
    local autoRaid = AUTO_DECK_RAIDS[deckName]
    local catalogDeckName = autoRaid or deckName
    local deck = RaidBingoCatalog and RaidBingoCatalog[catalogDeckName]
    if type(deck) ~= "table" then
        if autoRaid then return nil end
        print("Unknown deck; using the raid-generic pool.")
        deckName = "raid_generic"
        deck = RaidBingoCatalog and RaidBingoCatalog[deckName]
    end
    if type(deck) ~= "table" then
        return self:GetDefaultCard()
    end

    local pool = {}
    if autoRaid then
        pool = collectUniqueSquares(deck, nil, nil, isAutoMarkableSquare)
    elseif deckName == "raid_generic" then
        pool = collectUniqueSquares(deck)
    else
        -- Keep raid cards mostly generic, with a random handful of encounter
        -- squares so each raid-specific card feels different.
        local raidPool = collectUniqueSquares(deck)
        self:ShuffleTable(raidPool)
        local seenIds, seenText = {}, {}
        local specificCount = math.min(math.random(2, 8), #raidPool)
        for i = 1, specificCount do
            local square = raidPool[i]
            table.insert(pool, square)
            seenIds[square.id] = true
            seenText[string.lower(square.text)] = true
        end

        local genericPool = collectUniqueSquares(RaidBingoCatalog.raid_generic, seenIds, seenText)
        self:ShuffleTable(genericPool)
        for _, square in ipairs(genericPool) do
            if #pool >= AUTO_DECK_MINIMUM then break end
            table.insert(pool, square)
        end

        -- If the generic catalog is ever too small, fill remaining spaces with
        -- unused raid squares while still preventing duplicate IDs and text.
        if #pool < AUTO_DECK_MINIMUM then
            for i = specificCount + 1, #raidPool do
                local square = raidPool[i]
                local textKey = string.lower(square.text)
                if not seenIds[square.id] and not seenText[textKey] then
                    table.insert(pool, square)
                    seenIds[square.id] = true
                    seenText[textKey] = true
                    if #pool >= AUTO_DECK_MINIMUM then break end
                end
            end
        end
    end
    if #pool < AUTO_DECK_MINIMUM then
        print("This deck does not contain enough unique squares to make a full card.")
        if autoRaid then return nil end
        return self:GetDefaultCard()
    end

    self:ShuffleTable(pool)
    local freeSpaces = self:GenerateFreeSpacePositions()
    local newCard = { squares = {}, freeSpaces = freeSpaces, gridSize = 5, centerSquareIndex = 13 }
    local nextSquare = 1
    for i = 1, 25 do
        if freeSpaces[i] then
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
    return self:ApplyRandomFreeSpaces({
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
            "A raider discovers a forgotten snack between pulls",
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
    })
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
    title:SetText("Fantastiq Bingo TBC");

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
        local savedFreeSpaces = {}
        for index, square in ipairs(saved) do
            local text = type(square) == "table" and square.text or square
            if text == "Free Space" then savedFreeSpaces[index] = true end
        end
        local freeSpaces = RaidBingoDB.freeSpacePositions
        local freeSpaceCount = 0
        if type(freeSpaces) == "table" then
            local positionsMatchSquares = true
            for index = 1, 25 do
                if freeSpaces[index] then
                    freeSpaceCount = freeSpaceCount + 1
                end
                if (freeSpaces[index] == true) ~= (savedFreeSpaces[index] == true) then positionsMatchSquares = false end
            end
            if freeSpaceCount ~= 3 or not positionsMatchSquares then freeSpaces = nil end
        else
            for _ in pairs(savedFreeSpaces) do freeSpaceCount = freeSpaceCount + 1 end
            if freeSpaceCount == 3 then freeSpaces = savedFreeSpaces end
        end
        cardData = { squares = saved, freeSpaces = freeSpaces, gridSize = 5, centerSquareIndex = 13 }
        RaidBingoDB.freeSpacePositions = freeSpaces
    else
        cardData = self:GenerateCardFromCatalog(currentDeck)
        RaidBingoDB.cardSquares = cardData.squares
        RaidBingoDB.freeSpacePositions = cardData.freeSpaces
        RaidBingoDB.selectedDeck = currentDeck
        RaidBingoDB.playerMarks = {}
        RaidBingoDB.bingoAnnounced = false
        RaidBingoDB.bingoMilestone = 0
        playerMarks = RaidBingoDB.playerMarks
    end
    self.currentCard = cardData
    self.bingoMilestone = tonumber(RaidBingoDB.bingoMilestone) or (RaidBingoDB.bingoAnnounced and 1 or 0)
    self.bingoAnnounced = self.bingoMilestone > 0
    if self.mainFrame then self:UpdateCard() end
end

function addon:GetCurrentDeck()
    return currentDeck
end

function addon:GetAutoDeckOptions()
    return AUTO_DECKS
end

function addon:GetAutoDeckStatus(deckName)
    local raid = AUTO_DECK_RAIDS[deckName]
    local pool = RaidBingoCatalog and raid and RaidBingoCatalog[raid]
    local count = #collectUniqueSquares(pool, nil, nil, isAutoMarkableSquare)
    return count, count >= AUTO_DECK_MINIMUM, AUTO_DECK_MINIMUM
end

function addon:SelectDeck(deckName)
    local autoRaid = AUTO_DECK_RAIDS[deckName]
    if autoRaid then
        local count, available = self:GetAutoDeckStatus(deckName)
        if not available then
            print(string.format("%s Auto is unavailable: %d of %d verified event squares.", deckName, count, AUTO_DECK_MINIMUM))
            return false
        end
    elseif not RaidBingoCatalog or not RaidBingoCatalog[deckName] then
        return false
    end
    currentDeck = deckName
    RaidBingoDB.selectedDeck = deckName
    RaidBingoDB.playerMarks = {}
    RaidBingoDB.cardSquares = nil
    RaidBingoDB.freeSpacePositions = nil
    RaidBingoDB.bingoAnnounced = false
    RaidBingoDB.bingoMilestone = 0
    playerMarks = RaidBingoDB.playerMarks
    self.bingoMilestone = 0
    self.bingoAnnounced = false
    self:GenerateAndDisplayCard(true)
    if autoRaid then self:SetAutoMarkEnabled(true) end
    return true
end

function addon:NewCard()
    RaidBingoDB.playerMarks = {}
    RaidBingoDB.cardSquares = nil
    RaidBingoDB.freeSpacePositions = nil
    RaidBingoDB.bingoAnnounced = false
    RaidBingoDB.bingoMilestone = 0
    playerMarks = RaidBingoDB.playerMarks
    self.bingoMilestone = 0
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
    if self:IsFreeSpace(squareIndex) then return end
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
            if not self:IsFreeSpace(index) and not playerMarks[index] then
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
            if not self:IsFreeSpace(index) and not playerMarks[index] then
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

local function NormalizeEventText(value)
    return string.lower((value or ""):gsub("[^%w%s]", ""):gsub("%s+", " "):match("^%s*(.-)%s*$"))
end

local function ContainsEventPhrase(value, phrase)
    local haystack, needle = NormalizeEventText(value), NormalizeEventText(phrase)
    return needle ~= "" and haystack:find(needle, 1, true) ~= nil
end

local function GetNamedDeathTarget(square)
    if type(square) ~= "table" or type(square.text) ~= "string" then return nil end
    local target
    if square.category == "boss" then
        target = square.text:match("^[Dd]efeat%s+(.+)$")
    elseif square.category == "mob" then
        target = square.text:match("^[Kk]ill%s+[Aa]n?%s+(.+)$")
    end
    if not target then return nil end
    local normalized = NormalizeEventText(target)
    if normalized == "" or normalized:find("boss", 1, true)
        or normalized:find("specific", 1, true) or normalized:find("certain number", 1, true)
        or normalized:find("named mob", 1, true) or normalized:find("mob type", 1, true) then
        return nil
    end
    return target
end

local function ParseHitSquare(text)
    if type(text) ~= "string" then return nil, nil end
    local remainder = text:match("^[Gg]et hit by%s+(.+)$")
    if not remainder then return nil, nil end
    local splitAt = remainder:find("'s%s+") or remainder:find("’s%s+")
    if not splitAt then return nil, nil end
    local source = remainder:sub(1, splitAt - 1):gsub("^[Aa]%s+", ""):gsub("^[Tt]he%s+", "")
    local ability = remainder:sub(splitAt):gsub("^'s%s+", ""):gsub("^’s%s+", "")
    return source, ability
end

local function IsHitSubevent(subevent)
    return subevent == "SPELL_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE"
        or subevent == "SPELL_AURA_APPLIED"
end

local function SquareMatchesCombatEvent(square, subevent, sourceName, destName, destGUID, spellId, spellName)
    if type(square) ~= "table" then return false end

    -- Named boss defeats and mob kills are inferred from the death's destination
    -- name; generic boxes intentionally do not match arbitrary deaths.
    local deathTarget = GetNamedDeathTarget(square)
    if deathTarget and (subevent == "UNIT_DIED" or subevent == "PARTY_KILL")
        and ContainsEventPhrase(destName, deathTarget) then
        return true
    end

    if not IsHitSubevent(subevent) or destGUID ~= UnitGUID("player") then return false end

    -- The owner's Illidan blue-flame square maps to the ground-flame damage
    -- spell. The box text and mechanic are maintained together in its catalog entry.
    local rule = square.autoMark
    if type(rule) == "table" and rule.spellIds then
        for _, supportedSpellId in ipairs(rule.spellIds) do
            if spellId == supportedSpellId then return true end
        end
    end

    -- For explicit “Get hit by <creature>'s <spell>” boxes, match both the
    -- combat-log source and spell name against the displayed square wording.
    local sourceTerm, abilityTerm = ParseHitSquare(square.text)
    return sourceTerm ~= nil and abilityTerm ~= nil
        and ContainsEventPhrase(sourceName, sourceTerm)
        and ContainsEventPhrase(spellName, abilityTerm)
end

isAutoMarkableSquare = function(square)
    if type(square) ~= "table" or type(square.text) ~= "string" then return false end
    if GetNamedDeathTarget(square) then return true end

    local rule = square.autoMark
    if type(rule) == "table" and type(rule.spellIds) == "table" and #rule.spellIds > 0 then return true end

    local sourceTerm, abilityTerm = ParseHitSquare(square.text)
    if sourceTerm and abilityTerm then return true end
    return square.text:match("['\"]([^'\"]+)['\"]") ~= nil
end

function addon:SetAutoMarkEnabled(enabled)
    RaidBingoDB = RaidBingoDB or {}
    -- Classic clients have returned either true/false or 1/nil from
    -- CheckButton:GetChecked(); normalize every truthy checked value.
    RaidBingoDB.autoMarkEvents = not not enabled
    if self.autoMarkCheckbox then self.autoMarkCheckbox:SetChecked(RaidBingoDB.autoMarkEvents) end
    if eventFrame then
        if RaidBingoDB.autoMarkEvents then
            eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            eventFrame:RegisterEvent("CHAT_MSG_RAID")
            eventFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
            eventFrame:RegisterEvent("CHAT_MSG_RAID_WARNING")
            eventFrame:RegisterEvent("CHAT_MSG_PARTY")
            eventFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
            eventFrame:RegisterEvent("CHAT_MSG_SAY")
            eventFrame:RegisterEvent("CHAT_MSG_YELL")
        else
            eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            eventFrame:UnregisterEvent("CHAT_MSG_RAID")
            eventFrame:UnregisterEvent("CHAT_MSG_RAID_LEADER")
            eventFrame:UnregisterEvent("CHAT_MSG_RAID_WARNING")
            eventFrame:UnregisterEvent("CHAT_MSG_PARTY")
            eventFrame:UnregisterEvent("CHAT_MSG_PARTY_LEADER")
            eventFrame:UnregisterEvent("CHAT_MSG_SAY")
            eventFrame:UnregisterEvent("CHAT_MSG_YELL")
        end
    end
end

function addon:AutoMarkMatchingSquares(matcher)
    if not RaidBingoDB or not RaidBingoDB.autoMarkEvents then return end
    local squares = self:GetCardData().squares or {}
    local marks = self:GetPlayerMarks()
    local changed = false
    for index, square in ipairs(squares) do
        if not self:IsFreeSpace(index) and not marks[index] and matcher(square) then
            marks[index] = true
            changed = true
        end
    end
    if changed then
        self:SavePlayerMarks()
        self:UpdateCard()
        self:CheckForCompletedLines()
    end
end

function addon:OnCombatLogEvent()
    if not RaidBingoDB or not RaidBingoDB.autoMarkEvents or not CombatLogGetCurrentEventInfo then return end
    if not (UnitInRaid and UnitInRaid("player")) then return end
    local _, subevent, _, _, sourceName, _, _, destGUID, destName, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()
    self:AutoMarkMatchingSquares(function(square)
        return SquareMatchesCombatEvent(square, subevent, sourceName, destName, destGUID, spellId, spellName)
    end)
end

function addon:OnChatEvent(message)
    if not RaidBingoDB or not RaidBingoDB.autoMarkEvents or not (UnitInRaid and UnitInRaid("player")) then return end
    if type(message) ~= "string" then return end
    self:AutoMarkMatchingSquares(function(square)
        if type(square) ~= "table" or type(square.text) ~= "string" then return false end
        local quotedPhrase = square.text:match("['\"]([^'\"]+)['\"]")
        return quotedPhrase ~= nil and ContainsEventPhrase(message, quotedPhrase)
    end)
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
        RaidBingoDB.bingoMilestone = 0
        playerMarks = RaidBingoDB.playerMarks
        self.bingoMilestone = 0
        self.bingoAnnounced = false
        self:UpdateUI()
        print("Raid Bingo marks reset.")
    elseif msg == "new" then
        self:NewCard()
    elseif msg == "automark" then
        self:SetAutoMarkEnabled(not (RaidBingoDB and RaidBingoDB.autoMarkEvents))
        print("Raid Bingo event automarking: " .. (RaidBingoDB.autoMarkEvents and "on" or "off"))
    elseif decks[msg] then
        self:SelectDeck(decks[msg])
        print("Switched to " .. msg .. " bingo deck.")
    else
        print("Raid Bingo commands: /rb toggle, /rb new, /rb reset, /rb automark, /rb bt, /rb hyjal, /rb ssc, /rb tk, /rb za, /rb generic")
    end
end

-- Register slash command
SLASH_RAIDBINGO1 = "/rb";
SlashCmdList["RAIDBINGO"] = function(msg)
    addon:HandleCommand(msg);
end;

-- The addon namespace is a table, not a Frame. Use one real frame for initialization.
eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    local firstArg = ...
    if event == "ADDON_LOADED" and firstArg == addonName then
        addon:OnEnable()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        addon:OnCombatLogEvent()
    elseif event:match("^CHAT_MSG_") then
        addon:OnChatEvent(firstArg)
    end
end)

SLASH_RAIDBINGO2 = "/raidbingo"

-- Export the addon for use by other modules
RaidBingoAddon = addon;
