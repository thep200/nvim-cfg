-- ============================================================
--  lua/snippet/faker.lua
--  Snippet gen dữ liệu giả cho MỌI filetype.
--  File này đăng ký trực tiếp vào ft "all" qua ls.add_snippets
--  (tên file là faker.lua nên không dựa vào tên file như all.lua).
--    fname    -> tên người giả      (Python Faker)
--    femail   -> email giả          (Python Faker)
--    fip      -> IPv4 ngẫu nhiên    (Python Faker)
--    faddress -> địa chỉ giả        (Python Faker)
--    fchar<n> -> n ký tự ngẫu nhiên (VD: fchar16 + Tab)
--    fnum<n>  -> số ngẫu nhiên 0 -> n (VD: fnum1000 + Tab)
--  Cần: pip3 install faker. Mỗi lần expand gọi python3 (~200ms).
-- ============================================================

local ls = require("luasnip")
local s  = ls.snippet
local f  = ls.function_node

-- Hàm helper gọi Python Faker. Dùng vim.fn.system dạng LIST (không qua
-- shell) để method chứa nháy/ký tự đặc biệt không phá lệnh.
local function fake_data(faker_method)
    return f(function()
        local code = ("from faker import Faker; print(Faker().%s)"):format(faker_method)
        local result = vim.fn.system({ "python3", "-c", code })
        if vim.v.shell_error ~= 0 then
            return "<faker lỗi: " .. result:gsub("%s+", " "):sub(1, 80) .. ">"
        end
        -- Dọn ký tự thừa; địa chỉ nhiều dòng gộp thành 1 dòng
        return (result:gsub("\r", ""):gsub("\n$", ""):gsub("\n", ", "))
    end)
end

-- Bảng ký tự cho fchar<n>
local CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

ls.add_snippets("all", {
    -- Gõ 'fname' -> tên người (VD: Christopher Harris)
    s({ trig = "fname", desc = "Faker: person name" }, { fake_data("name()") }),

    -- Gõ 'femail' -> email giả (VD: harris@example.com)
    s({ trig = "femail", desc = "Faker: email" }, { fake_data("email()") }),

    -- Gõ 'fip' -> IPv4 ngẫu nhiên (VD: 192.168.1.1)
    s({ trig = "fip", desc = "Faker: IPv4" }, { fake_data("ipv4()") }),

    -- Gõ 'faddress' -> địa chỉ ngẫu nhiên (1 dòng)
    s({ trig = "faddress", desc = "Faker: address" }, { fake_data("address()") }),

    -- Snippet ĐỘNG (regex trigger): n nằm trong trigger, VD fchar16
    s({
        trig    = "fchar(%d+)",
        regTrig = true,
        desc    = "fchar<n>: n random characters",
    }, f(function(_, snip)
        local n = math.min(tonumber(snip.captures[1]) or 0, 4096)
        local out = {}
        for i = 1, n do
            local r = math.random(1, #CHARS)
            out[i] = CHARS:sub(r, r)
        end
        return table.concat(out)
    end)),

    -- Số ngẫu nhiên 0..n, n nằm trong trigger: fnum1000, fnum50, ...
    s({
        trig    = "fnum(%d+)",
        regTrig = true,
        desc    = "fnum<n>: random number 0..n",
    }, f(function(_, snip)
        local max = tonumber(snip.captures[1]) or 0
        return tostring(math.random(0, max))
    end)),
})
