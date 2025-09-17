-- Checks if a table contains an object as a key or as a value
-- Returns a key of the table if this object is found
function table.containsObj(tab, obj, valueOnly)
    if type(tab) ~= "table" then
        error("Can't use table.containsObj with a " .. type(tab) .. "!", 2)
    end
    for k, v in pairs(tab) do
        if (not valueOnly and k == obj) or v == obj then
            return k
        end
    end
    return false
end

-- Copies a table
function table.copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.copy(orig_key)] = table.copy(orig_value)
        end
        setmetatable(copy, table.copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Returns a table with a prefix. Strings only.
function table.add_prefix(prefix, table)
    for k, v in pairs(table) do
        table[k] = prefix .. v
    end

    return table
end

-- Checks if a string ends with another string
function string.ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

-- Takes a string and returns a table of strings between the characters we were searching for
-- Ex: string.split("test:testy", ":") --> { "test", "testy" }
-- Improved by WD200019
function string.split(inputstr, sep, isPattern)
    if sep == nil then
        sep = "%s"
    end
    local t = { }
    if isPattern then
        while string.find(inputstr, sep) ~= nil do
            local matchrange = { string.find(inputstr, sep) }
            local preceding = string.sub(inputstr, 0, matchrange[1] - 1)
            table.insert(t, preceding ~= "" and preceding or nil)
            inputstr = string.sub(inputstr, matchrange[2] + 1)
        end
        table.insert(t, inputstr)
    else
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
        end
    end
    return t
end

-- Scrambles a string in such way it's rendered nonsensical.
function string.scramble(str)
    -- Ignore scrambling.
    if str[1] == "°" then
        return str:sub(2)
    else
        local posit = {}
        for i=1, #str do
            table.insert(posit, i)
        end

        local newstring = ""
        local len = #posit
        for j=1, #posit do
            local is = math.random(len)
            local inter = posit[is]
            newstring = newstring .. str[inter]

            table.remove(posit, is)
            len = len-1
        end

        return newstring
    end
end

function table.read(table)
    local decoytext = ""
    for key, value in pairs(table) do
        local k = tostring(value)
        if not(k.find(k, "table") == nil) then
            k = ""
            for _key, _value in pairs(value) do
                k = k .. _key .. ":    " .. tostring(_value) .. ". "
            end
        end
        decoytext = decoytext .. key .. ":    " .. tostring(k) .. ". "
    end

    return decoytext
end
-- thanks to RCIX
function table.merge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

-- Parses a base 10 number into a base 16 number (unsigned)
function NumberToHex(number)
    number = math.abs(number)
    local startNumber = number
    local hex = ""
    if type(number) == "number" then
        repeat
            local tempHex = number % 16
            number = math.floor(number / 16)
            hex = (tempHex < 10 and tostring(tempHex) or tostring(string.char(string.byte('a') + tempHex - 10))) .. hex
        until number == 0
    else
        error("NumberToHex() needs a number variable.", 2)
    end

    return hex
end

function lerp(start, destination, amo)
    local distance = destination - start
    return distance*amo
end

function math.sign(x)
    return x>0 and 1 or x<0 and -1 or 0
end
function math.clamp(val, lower, upper) --by vlrd
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

-- Counts the number of digits in a number
-- The minus is counted as a digit
function CountDigits(number)
    if number == 0 then return 1 end

    local count = 0
    while number ~= 0 do
        if number < 0 then
            number = -number
        else
            number = math.floor(number / 10)
        end
        count = count + 1
    end
    return count
end

-- Loads an Entity file
function LoadEntityFile(_ENV_BASE, path, CYK)
    -- Very complex _ENV swap
    sandboxENV = table.copy(_ENV_BASE)
    sandboxENV._G = { oldENV = _ENV }
    sandboxENV.CYK = CYK
    sandboxENV.Encounter = _ENV
    sandboxENV.self = sandboxENV
    _ENV = sandboxENV

    local modName = GetModName()
    dofile (modName .. "/Lua/Libraries/CYK/Sandboxing/Entity.lua")(_ENV)
    dofile (modName .. "/Lua/" .. path .. ".lua")(_ENV)

    -- Back to the old _ENV
    _G.oldENV.newENV = _ENV
    _ENV = _G.oldENV
    local newENV2 = newENV
    sandboxENV = nil
    newENV = nil

    return newENV2
end

-- Checks if a variable is a valid text or text container
function CheckText(text, allowNil, isTextContainer)
    -- Text is nil
    if not text then
        if allowNil then return true, nil
        else             return false, "nil"
        end
    -- Text is a table
    elseif type(text) == "table" then
        if #text == 0 then
            return false, "empty"
        end
        for j = 1, #text do
            -- One of the values isn't a string (or table if text is a text container)
            if type(text[j]) ~= "string" and not (type(text[j]) == "table" and isTextContainer) then
                return false, tostring(i) .. "nostr"
            end
        end
        return true, text
    -- Text is a string and not a text container
    elseif not isTextContainer and type(text) == "string" then
        return true, { text }
    else
        return false, "nostr"
    end
end

-- Returns the name of the mod
-- Credits to WD for this handy function!
function GetModName()
    local testError = function()
        CreateProjectile("asdbfiosdjfaosdijcfiosdjsdo", 0, 0)
    end

    local _, output = xpcall(testError, debug.traceback)

    -- Find the position of "Sprites/asdbfiosdjfaosdijcfiosdjsdo"
    local SpritesFolderPos = output:find("asdbfiosdjfaosdijcfiosdjsdo") - 10
    output = output:sub(1, SpritesFolderPos)

    local paths = string.split(output, "Attempted to load ", true)
    return paths[#paths]
end

function PlaySoundOnceThisFrame(sound)
    if not NewAudio.Exists(sound) then
        NewAudio.CreateChannel(sound)
    end
    NewAudio.PlaySound(sound, sound)
end

-- Allows to get characters from a string like we'd get a value in tables
-- Ex: a = "abcdef"; a[4] --> d
getmetatable('').__index = function(str,i)
    if type(i) == 'number' then
        return string.sub(str,i,i)
    else
        return string[i]
    end
end