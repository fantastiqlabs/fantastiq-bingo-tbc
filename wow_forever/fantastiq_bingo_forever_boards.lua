local addonName, addon = ...

local BOARD_SIZE = 25
local FREE_SPACE_INDEX = 13
local HISTORY_LIMIT = 20
local SCHEMA_VERSION = 1
local RANDOM_MODULUS = 2147483647

local function copyCell(cell)
    local copy = {
        free = cell.free == true,
        objectiveId = cell.objectiveId,
        category = cell.category,
        text = cell.text,
        marking = cell.marking,
    }
    if type(cell.dungeon) == "string" then copy.dungeon = cell.dungeon end
    if type(cell.region) == "string" then copy.region = cell.region end
    if type(cell.mark) == "table" then
        copy.mark = { source = cell.mark.source, event = cell.mark.event }
    end
    return copy
end

local function copyBoard(board)
    local copy = {
        id = board.id,
        mode = board.mode,
        minLevel = board.minLevel,
        maxLevel = board.maxLevel,
        seed = board.seed,
        createdAt = board.createdAt,
        cells = {},
    }
    for index, cell in ipairs(board.cells) do copy.cells[index] = copyCell(cell) end
    return copy
end

local function freshDatabase()
    return { schemaVersion = SCHEMA_VERSION, boards = {}, history = {} }
end

local function listContains(values, target)
    for _, value in ipairs(values) do
        if value == target then return true end
    end
    return false
end

local function isSavedBoard(board)
    if type(board) ~= "table" or type(board.id) ~= "string" or board.id == "" then return false end
    if board.mode ~= "solo" and board.mode ~= "group" then return false end
    if type(board.minLevel) ~= "number" or type(board.maxLevel) ~= "number"
        or board.minLevel % 1 ~= 0 or board.maxLevel % 1 ~= 0
        or board.minLevel < 1 or board.maxLevel > 60 or board.minLevel > board.maxLevel then return false end
    if type(board.seed) ~= "number" or type(board.cells) ~= "table" or #board.cells ~= BOARD_SIZE then return false end
    for index = 1, BOARD_SIZE do
        local cell = board.cells[index]
        if type(cell) ~= "table" or type(cell.text) ~= "string" then return false end
        if index == FREE_SPACE_INDEX then
            if cell.free ~= true or type(cell.mark) ~= "table" or cell.mark.source ~= "free" then return false end
        elseif type(cell.objectiveId) ~= "string" then
            return false
        elseif cell.marking ~= "manual" and cell.marking ~= "verified_event" then
            return false
        end
        if cell.mark ~= nil and type(cell.mark) ~= "table" then return false end
        if type(cell.mark) == "table" and cell.mark.source ~= "manual" and cell.mark.source ~= "verified_event" and cell.mark.source ~= "free" then
            return false
        end
        if type(cell.mark) == "table" and cell.mark.source == "verified_event"
            and (cell.marking ~= "verified_event" or type(cell.mark.event) ~= "string" or cell.mark.event == "") then
            return false
        end
    end
    return true
end

function addon.InitializeSavedVariables()
    local raw = _G.FantastiqBingoForeverDB
    local db = freshDatabase()
    local recovered = false
    if type(raw) == "table" and raw.schemaVersion == SCHEMA_VERSION
        and type(raw.boards) == "table" and type(raw.history) == "table" then
        for id, board in pairs(raw.boards) do
            if type(id) == "string" and isSavedBoard(board) and board.id == id then
                db.boards[id] = copyBoard(board)
            else
                recovered = true
            end
        end
        for _, id in ipairs(raw.history) do
            if type(id) == "string" and db.boards[id] and not listContains(db.history, id) then
                db.history[#db.history + 1] = id
            else
                recovered = true
            end
        end
        if type(raw.currentBoardId) == "string" and db.boards[raw.currentBoardId] then
            db.currentBoardId = raw.currentBoardId
        elseif raw.currentBoardId ~= nil then
            recovered = true
        end
    elseif raw ~= nil then
        recovered = true
    end
    if recovered then db.recoveryNotice = "Some saved Bingo data was invalid and has been safely skipped." end
    _G.FantastiqBingoForeverDB = db
    addon.db = db
    return db
end

local function normalizeSeed(seed)
    local numeric = tonumber(seed)
    if not numeric or numeric ~= numeric or numeric == math.huge or numeric == -math.huge then
        numeric = type(time) == "function" and time() or 1
    end
    numeric = math.floor(math.abs(numeric)) % (RANDOM_MODULUS - 1) + 1
    return numeric
end

local function nextRandom(state)
    return (state * 48271) % RANDOM_MODULUS
end

local function hasMode(item, mode)
    for _, itemMode in ipairs(item.modes or {}) do
        if itemMode == mode then return true end
    end
    return false
end

function addon.GenerateBoard(mode, minLevel, maxLevel, seed)
    if mode ~= "solo" and mode ~= "group" then return nil, "mode must be solo or group" end
    if type(minLevel) ~= "number" or type(maxLevel) ~= "number"
        or minLevel % 1 ~= 0 or maxLevel % 1 ~= 0
        or minLevel < 1 or maxLevel > 60 or minLevel > maxLevel then
        return nil, "level range must be ordered and within 1-60"
    end

    local eligible = {}
    for _, item in ipairs(addon.catalog or {}) do
        if hasMode(item, mode) and item.minLevel <= maxLevel and item.maxLevel >= minLevel then
            eligible[#eligible + 1] = item
        end
    end
    if #eligible < BOARD_SIZE - 1 then
        return nil, string.format("only %d eligible objectives; need at least %d", #eligible, BOARD_SIZE - 1)
    end
    table.sort(eligible, function(left, right) return left.id < right.id end)

    local normalizedSeed = normalizeSeed(seed)
    local state = normalizedSeed
    for index = #eligible, 2, -1 do
        state = nextRandom(state)
        local other = (state % index) + 1
        eligible[index], eligible[other] = eligible[other], eligible[index]
    end

    local board = {
        mode = mode,
        minLevel = minLevel,
        maxLevel = maxLevel,
        seed = normalizedSeed,
        id = string.format("%s_%d_%d_%d", mode, minLevel, maxLevel, normalizedSeed),
        createdAt = type(time) == "function" and time() or 0,
        cells = {},
    }
    for index = 1, BOARD_SIZE do
        if index == FREE_SPACE_INDEX then
            board.cells[index] = { free = true, text = "Free Space", mark = { source = "free" } }
        else
            local item = table.remove(eligible, 1)
            board.cells[index] = {
                objectiveId = item.id,
                category = item.category,
                text = item.text,
                marking = item.marking,
                dungeon = item.dungeon,
                region = item.region,
            }
        end
    end
    return board
end

function addon.SaveBoard(board)
    if not isSavedBoard(board) then return false, "board data is malformed" end
    local db = addon.db or addon.InitializeSavedVariables()
    local saved = copyBoard(board)
    db.boards[saved.id] = saved
    db.currentBoardId = saved.id
    for index, id in ipairs(db.history) do
        if id == saved.id then table.remove(db.history, index) break end
    end
    table.insert(db.history, 1, saved.id)
    while #db.history > HISTORY_LIMIT do
        local expiredId = table.remove(db.history)
        if expiredId ~= db.currentBoardId then db.boards[expiredId] = nil end
    end
    return true
end

function addon.LoadBoard(id)
    local db = addon.db or addon.InitializeSavedVariables()
    local board = db.boards[id]
    if not isSavedBoard(board) then return nil end
    db.currentBoardId = id
    return copyBoard(board)
end

function addon.OpenBoard(mode, minLevel, maxLevel, seed)
    local board, err = addon.GenerateBoard(mode, minLevel, maxLevel, seed)
    if not board then return nil, err end
    local existing = addon.LoadBoard(board.id)
    if existing then return existing end
    local saved, saveError = addon.SaveBoard(board)
    if not saved then return nil, saveError end
    return board
end

function addon.MarkSquare(board, index, source, eventName)
    if not isSavedBoard(board) then return false, "board data is malformed" end
    if type(index) ~= "number" or index < 1 or index > BOARD_SIZE or index % 1 ~= 0 then
        return false, "square index must be between 1 and 25"
    end
    local cell = board.cells[index]
    if cell.free then return false, "the free space is already marked" end
    source = source or "manual"
    if source ~= "manual" and source ~= "verified_event" then return false, "unsupported mark source" end
    if source == "verified_event" and (cell.marking ~= "verified_event" or type(eventName) ~= "string" or eventName == "") then
        return false, "this objective has no verified event mark" 
    end
    cell.mark = { source = source, event = source == "verified_event" and eventName or nil }
    return addon.SaveBoard(board)
end

function addon.UnmarkSquare(board, index)
    if not isSavedBoard(board) then return false, "board data is malformed" end
    if type(index) ~= "number" or index < 1 or index > BOARD_SIZE or index % 1 ~= 0 then
        return false, "square index must be between 1 and 25"
    end
    if board.cells[index].free then return false, "the free space cannot be unmarked" end
    board.cells[index].mark = nil
    return addon.SaveBoard(board)
end

addon.boardConstants = {
    size = BOARD_SIZE,
    freeSpaceIndex = FREE_SPACE_INDEX,
    historyLimit = HISTORY_LIMIT,
}
