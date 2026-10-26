local addon = {}
local messages, emotes = {}, {}
RaidBingoDB = { playerMarks = {} }
GameFontNormal = { GetFont = function() return "test-font", 12, "" end }
SendChatMessage = function(message, channel) messages[#messages + 1] = { message, channel } end
DoEmote = function(emote) emotes[#emotes + 1] = emote end
assert(loadfile("raid_bingo_ui.lua"))("raid_bingo_addon", addon)
function addon:GetPlayerMarks() return RaidBingoDB.playerMarks end
function addon:SavePlayerMarks() end
function addon:UpdateCard() end
local function mark(index) addon:ToggleMark(index) end
local function expectAnnouncement(index, prefix)
    assert(messages[index], "missing announcement " .. prefix)
    assert(messages[index][1]:match("^" .. prefix), "wrong announcement: " .. messages[index][1])
    assert(messages[index][2] == "YELL", "announcement must use YELL")
    assert(messages[index][1]:match("! .+"), "announcement must include a random quote")
    assert(emotes[index] == "LAUGH", "announcement must be followed by LAUGH")
end
for index = 1, 5 do mark(index) end
expectAnnouncement(1, "BINGO 1 ROW")
for index = 6, 10 do mark(index) end
expectAnnouncement(2, "BINGO TWO ROWS")
for index = 11, 25 do if index ~= 13 then mark(index) end end
expectAnnouncement(3, "BINGO FULL BOARD")
assert(#messages == 3, "each milestone should announce only once")

-- Existing saves only have bingoAnnounced; migrate them as a first-row win.
RaidBingoDB = { playerMarks = {}, bingoAnnounced = true }
addon.bingoMilestone = nil
messages, emotes = {}, {}
for index = 1, 5 do mark(index) end
assert(#messages == 0, "legacy save must not repeat the first-row yell")
for index = 6, 10 do mark(index) end
expectAnnouncement(1, "BINGO TWO ROWS")
print("PASS: bingo milestones yell once with a quote and laugh, including legacy saves")
