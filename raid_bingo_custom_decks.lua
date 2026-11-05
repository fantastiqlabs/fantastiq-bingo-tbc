-- Strict, deliberately small JSON format for user-authored text-only decks.
local addonName, addon = ...
local Codec = {}
addon.CustomDeckCodec = Codec

local MAX_BYTES, MAX_DECKS, MAX_PROMPTS = 8192, 20, 100
local function fail(message) return nil, message end

local function encodeString(value)
    return '"' .. value:gsub('[%z\1-\31\\"]', function(char)
        local escapes = { ['\\'] = '\\\\', ['"'] = '\\"', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t', ['\b'] = '\\b', ['\f'] = '\\f' }
        return escapes[char] or string.format('\\u%04x', string.byte(char))
    end) .. '"'
end

function Codec.Encode(deck)
    local valid, message = Codec.Validate(deck)
    if not valid then return nil, message end
    local prompts = {}
    for _, prompt in ipairs(deck.prompts) do prompts[#prompts + 1] = encodeString(prompt) end
    return '{"format":"fantastiq-bingo-deck","version":1,"name":' .. encodeString(deck.name)
        .. ',"prompts":[' .. table.concat(prompts, ',') .. ']}'
end

local function utf8(codepoint)
    if codepoint < 0x80 then return string.char(codepoint) end
    if codepoint < 0x800 then return string.char(0xC0 + math.floor(codepoint / 0x40), 0x80 + codepoint % 0x40) end
    if codepoint < 0x10000 then return string.char(0xE0 + math.floor(codepoint / 0x1000), 0x80 + math.floor(codepoint / 0x40) % 0x40, 0x80 + codepoint % 0x40) end
    return string.char(0xF0 + math.floor(codepoint / 0x40000), 0x80 + math.floor(codepoint / 0x1000) % 0x40, 0x80 + math.floor(codepoint / 0x40) % 0x40, 0x80 + codepoint % 0x40)
end

local function parseJSON(source)
    local index, length = 1, #source
    local function whitespace()
        while source:sub(index, index):match("[%s]") do index = index + 1 end
    end
    local parseValue
    local function parseString()
        if source:sub(index, index) ~= '"' then error("Expected a JSON string") end
        index = index + 1
        local parts = {}
        while index <= length do
            local char = source:sub(index, index)
            index = index + 1
            if char == '"' then return table.concat(parts) end
            if char == "\\" then
                local escape = source:sub(index, index); index = index + 1
                local simple = { ['"'] = '"', ['\\'] = '\\', ['/'] = '/', b = '\b', f = '\f', n = '\n', r = '\r', t = '\t' }
                if simple[escape] then parts[#parts + 1] = simple[escape]
                elseif escape == 'u' then
                    local hex = source:sub(index, index + 3)
                    if not hex:match('^%x%x%x%x$') then error("Invalid Unicode escape") end
                    index = index + 4
                    local code = tonumber(hex, 16)
                    if code >= 0xD800 and code <= 0xDBFF then
                        if source:sub(index, index + 1) ~= '\\u' then error("Invalid Unicode surrogate pair") end
                        local low = source:sub(index + 2, index + 5)
                        if not low:match('^%x%x%x%x$') or tonumber(low, 16) < 0xDC00 or tonumber(low, 16) > 0xDFFF then error("Invalid Unicode surrogate pair") end
                        code = 0x10000 + (code - 0xD800) * 0x400 + tonumber(low, 16) - 0xDC00
                        index = index + 6
                    elseif code >= 0xDC00 and code <= 0xDFFF then error("Invalid Unicode surrogate pair") end
                    parts[#parts + 1] = utf8(code)
                else error("Invalid JSON string escape") end
            elseif string.byte(char) < 32 then error("Unescaped control character")
            else parts[#parts + 1] = char end
        end
        error("Unterminated JSON string")
    end
    local function parseObject(depth)
        index = index + 1; whitespace()
        local object = {}
        if source:sub(index, index) == '}' then index = index + 1; return object end
        while true do
            whitespace(); local key = parseString(); whitespace()
            if source:sub(index, index) ~= ':' then error("Expected ':'") end
            index = index + 1; whitespace()
            if object[key] ~= nil then error("Duplicate JSON field: " .. key) end
            object[key] = parseValue(depth + 1); whitespace()
            local delimiter = source:sub(index, index); index = index + 1
            if delimiter == '}' then return object end
            if delimiter ~= ',' then error("Expected ',' or '}'") end
        end
    end
    local function parseArray(depth)
        index = index + 1; whitespace()
        local array = {}
        if source:sub(index, index) == ']' then index = index + 1; return array end
        while true do
            array[#array + 1] = parseValue(depth + 1); whitespace()
            local delimiter = source:sub(index, index); index = index + 1
            if delimiter == ']' then return array end
            if delimiter ~= ',' then error("Expected ',' or ']'") end
        end
    end
    parseValue = function(depth)
        if depth > 4 then error("JSON nesting is too deep") end
        whitespace()
        local char = source:sub(index, index)
        if char == '"' then return parseString() end
        if char == '{' then return parseObject(depth) end
        if char == '[' then return parseArray(depth) end
        for literal, value in pairs({ ['true'] = true, ['false'] = false, ['null'] = false }) do
            if source:sub(index, index + #literal - 1) == literal then index = index + #literal; return value end
        end
        local number = source:sub(index):match('^-?%d+%.?%d*[eE]?[+-]?%d*')
        if number and number ~= '' then index = index + #number; return tonumber(number) end
        error("Invalid JSON value")
    end
    local value = parseValue(0); whitespace()
    if index <= length then error("Unexpected content after JSON value") end
    return value
end

function Codec.Validate(deck)
    if type(deck) ~= "table" then return fail("Deck must be a JSON object.") end
    for key in pairs(deck) do
        if key ~= "format" and key ~= "version" and key ~= "name" and key ~= "prompts" then return fail("Unsupported field: " .. tostring(key)) end
    end
    if deck.format ~= "fantastiq-bingo-deck" then return fail("This is not a Fantastiq Bingo deck.") end
    if deck.version ~= 1 then return fail("Unsupported deck format version.") end
    if type(deck.name) ~= "string" or #deck.name < 1 or #deck.name > 48 or deck.name:find("[%z\1-\31]") then return fail("Deck name must be 1–48 printable characters.") end
    if type(deck.prompts) ~= "table" or #deck.prompts < 24 or #deck.prompts > MAX_PROMPTS then return fail("A deck needs 24–100 prompts.") end
    local seen, count = {}, 0
    for key in pairs(deck.prompts) do
        if type(key) ~= "number" or key < 1 or key > #deck.prompts or key % 1 ~= 0 then return fail("Prompt list must be a simple array.") end
        count = count + 1
    end
    if count ~= #deck.prompts then return fail("Prompt list cannot contain gaps.") end
    for _, prompt in ipairs(deck.prompts) do
        if type(prompt) ~= "string" then return fail("Every prompt must be text.") end
        local trimmed = prompt:match("^%s*(.-)%s*$")
        if #trimmed == 0 or #trimmed > 50 or trimmed:find("[%z\1-\31]") then return fail("Prompts must contain 1–50 printable characters.") end
        local normalized = trimmed:lower():gsub("%s+", " ")
        if seen[normalized] then return fail("Duplicate prompt: " .. trimmed) end
        seen[normalized] = true
    end
    return true
end

function Codec.Decode(source)
    if type(source) ~= "string" or #source > MAX_BYTES then return fail("Deck JSON exceeds the 8 KiB limit.") end
    local ok, deck = pcall(parseJSON, source)
    if not ok then return fail("Invalid deck JSON: " .. tostring(deck)) end
    local valid, message = Codec.Validate(deck)
    if not valid then return fail(message) end
    return deck
end

function Codec.MaxDecks() return MAX_DECKS end
