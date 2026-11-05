#!/usr/bin/env lua
local addon = {}
local function loadAddonFile(path)
    local chunk, err = loadfile(path)
    assert(chunk, err)
    chunk("fantastiq_bingo_forever", addon)
end

loadAddonFile("wow_forever/fantastiq_bingo_forever_catalog.lua")
loadAddonFile("wow_forever/fantastiq_bingo_forever_boards.lua")

local first = assert(addon.GenerateBoard("solo", 11, 20, 4242))
local repeated = assert(addon.GenerateBoard("solo", 11, 20, 4242))
assert(#first.cells == 25, "board must have 25 cells")
assert(first.cells[13].free and first.cells[13].mark.source == "free", "center free space must stay marked")
assert(first.id == repeated.id, "same board inputs must have the same ID")

local seen = {}
for index = 1, 25 do
    local left, right = first.cells[index], repeated.cells[index]
    assert(left.objectiveId == right.objectiveId, "same seed must reproduce objective order")
    if not left.free then
        assert(not seen[left.objectiveId], "board must not contain duplicate objectives")
        seen[left.objectiveId] = true
    end
end

local changedSeed = assert(addon.GenerateBoard("solo", 11, 20, 4243))
local hasDifferentOrder = false
for index = 1, 25 do
    if first.cells[index].objectiveId ~= changedSeed.cells[index].objectiveId then
        hasDifferentOrder = true
        break
    end
end
assert(hasDifferentOrder, "different seeds should produce a different order")

local group = assert(addon.GenerateBoard("group", 31, 40, 4242))
for _, cell in ipairs(group.cells) do
    if cell.objectiveId then
        local found
        for _, item in ipairs(addon.catalog) do
            if item.id == cell.objectiveId then found = item break end
        end
        assert(found, "board objective must exist in catalog")
        assert(found.minLevel <= 40 and found.maxLevel >= 31, "board objective must overlap the selected band")
        local groupEligible = false
        for _, mode in ipairs(found.modes) do if mode == "group" then groupEligible = true end end
        assert(groupEligible, "solo-only objective must not appear on group board")
    end
end

assert(addon.InitializeSavedVariables())
local ok = addon.SaveBoard(first)
assert(ok, "board should save")
assert(addon.MarkSquare(first, 1, "manual"), "manual mark should save")
local reopened = assert(addon.LoadBoard(first.id), "saved board should reopen")
assert(reopened.cells[1].mark and reopened.cells[1].mark.source == "manual", "reopened board should restore local mark")
local selectedAgain = assert(addon.OpenBoard("solo", 11, 20, 4242))
assert(selectedAgain.cells[1].mark and selectedAgain.cells[1].mark.source == "manual", "selecting a saved seed should restore its marks")
assert(not addon.MarkSquare(reopened, 13, "manual"), "free space should not be manually changed")
assert(addon.UnmarkSquare(reopened, 1), "manual mark should be removable")
local reopenedAgain = assert(addon.LoadBoard(first.id))
assert(reopenedAgain.cells[1].mark == nil, "unmark should persist")

_G.FantastiqBingoForeverDB = { schemaVersion = 1, boards = "corrupt", history = {} }
local recovered = addon.InitializeSavedVariables()
assert(recovered.schemaVersion == 1 and type(recovered.boards) == "table", "malformed state should recover to a usable database")
assert(recovered.recoveryNotice, "recovery should be visible to the player")

print("Forever board tests passed: seeded order, free space, filtering, save/reopen, marks, and malformed-state recovery")
