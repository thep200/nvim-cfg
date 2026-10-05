-- ============================================================
--  lua/snippet/all.lua
-- ============================================================

local ls = require("luasnip")
local s  = ls.snippet
local f  = ls.function_node

math.randomseed(vim.uv.hrtime() % 2147483647)

local function uuid_v4()
    local out = ("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
    end)
    return out
end

-- ULID: 48 bit timestamp ms + 80 bit ngẫu nhiên, Crockford base32
local ULID_CHARS = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

local function ulid()
    local sec, usec = vim.uv.gettimeofday()
    local ms = sec * 1000 + math.floor(usec / 1000)
    local out = {}
    for i = 10, 1, -1 do
        local mod = ms % 32
        out[i] = ULID_CHARS:sub(mod + 1, mod + 1)
        ms = math.floor(ms / 32)
    end
    for i = 11, 26 do
        local r = math.random(0, 31)
        out[i] = ULID_CHARS:sub(r + 1, r + 1)
    end
    return table.concat(out)
end

local function ts_ms()
    local sec, usec = vim.uv.gettimeofday()
    return string.format("%d", sec * 1000 + math.floor(usec / 1000))
end

return {
    s({ trig = "uuid", desc = "Random UUID v4" }, f(uuid_v4)),
    s({ trig = "date", desc = "Date YYYY-MM-DD" }, f(function() return os.date("%Y-%m-%d") end)),
    s({ trig = "time", desc = "Time HH:MM:SS" }, f(function() return os.date("%H:%M:%S") end)),
    s({ trig = "now", desc = "Datetime YYYY-MM-DD HH:MM:SS" }, f(function() return os.date("%Y-%m-%d %H:%M:%S") end)),
    s({ trig = "iso", desc = "RFC3339 UTC timestamp" }, f(function() return os.date("!%Y-%m-%dT%H:%M:%SZ") end)),
    s({ trig = "ulid", desc = "ULID (time-sortable)" }, f(ulid)),
    s({ trig = "ts", desc = "Unix timestamp (seconds)" }, f(function() return tostring(os.time()) end)),
    s({ trig = "tsms", desc = "Unix timestamp (milliseconds)" }, f(ts_ms)),
}
