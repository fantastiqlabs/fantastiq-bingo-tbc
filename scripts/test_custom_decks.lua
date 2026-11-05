local addon = {}
assert(loadfile("raid_bingo_custom_decks.lua"))("test", addon)
local codec = addon.CustomDeckCodec

local prompts = {}
for index = 1, 24 do prompts[index] = "Prompt number " .. index end
prompts[24] = "os.execute('this remains plain text')"
prompts[1] = 'A "quoted" prompt with a \\ slash'
local deck = { format = "fantastiq-bingo-deck", version = 1, name = "Friends night", prompts = prompts }

local encoded, encodeError = codec.Encode(deck)
assert(encoded, encodeError)
local decoded, decodeError = codec.Decode(encoded)
assert(decoded, decodeError)
assert(decoded.name == deck.name and #decoded.prompts == 24)
assert(decoded.prompts[24] == prompts[24], "Lua-like prompt text must stay inert and unchanged")
assert(decoded.prompts[1] == prompts[1], "JSON quoting and backslash escapes must round-trip")

local duplicate = {}
for index, prompt in ipairs(prompts) do duplicate[index] = prompt end
duplicate[24] = duplicate[1]
local valid = codec.Validate({ format = deck.format, version = 1, name = deck.name, prompts = duplicate })
assert(not valid, "duplicate prompts must be rejected")

local unknownField = encoded:gsub('"prompts":', '"eventRules":{},"prompts":', 1)
local imported = codec.Decode(unknownField)
assert(not imported, "unknown executable metadata must be rejected")

local duplicateField = encoded:gsub('"version":1', '"version":1,"version":1', 1)
imported = codec.Decode(duplicateField)
assert(not imported, "duplicate JSON fields must be rejected")

imported = codec.Decode(string.rep("x", 8193))
assert(not imported, "oversized files must be rejected")

local tooFew = {}
for index = 1, 23 do tooFew[index] = prompts[index] end
valid = codec.Validate({ format = deck.format, version = 1, name = deck.name, prompts = tooFew })
assert(not valid, "decks with fewer than 24 prompts must be rejected")

local futureVersion = encoded:gsub('"version":1', '"version":2', 1)
imported = codec.Decode(futureVersion)
assert(not imported, "unsupported format versions must be rejected")

local unicode = encoded:gsub("Friends night", "Friends \\uD83C\\uDFB5")
local unicodeDeck = codec.Decode(unicode)
assert(unicodeDeck and unicodeDeck.name == "Friends 🎵", "valid Unicode escapes should decode")

print("Custom deck codec checks passed: round-trip, duplicates, unknown fields, size limit, inert prompt text, Unicode.")
