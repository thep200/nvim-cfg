-- ============================================================
--  lua/animation/hooks.lua
--  Gắn hiệu ứng bump vào các motion ngoài flash.
--  Hiện tại:
--    - GLOBAL mark jump (`A..`Z, 'A..'Z — nhảy xuyên file)
--    - Jumplist: <C-o> (back) và <Tab>/<C-i> (forward)
--  Mark thường a-z và các mark đặc biệt giữ nguyên native.
-- ============================================================

local M = {}

-- Chạy motion qua normal! rồi vẽ bump: co vào tại điểm đứng (chỉ khi
-- chưa chuyển sang file khác), nở ra tại điểm đến. Con trỏ không di
-- chuyển (vd <C-o> đã hết jumplist) thì không vẽ gì.
local function bump_jump(keys)
    local anim = require("animation.bump")
    local from_buf = vim.api.nvim_get_current_buf()
    local from = vim.api.nvim_win_get_cursor(0)

    local ok, err = pcall(vim.cmd, "normal! " .. keys)
    if not ok then
        -- Lỗi như native (vd E20 mark chưa đặt), không bump
        vim.api.nvim_echo({ { err:match("E%d+:[^\n]*") or err, "ErrorMsg" } }, false, {})
        return
    end

    local to_buf = vim.api.nvim_get_current_buf()
    local to = vim.api.nvim_win_get_cursor(0)
    if to_buf == from_buf and to[1] == from[1] and to[2] == from[2] then
        return
    end

    if to_buf == from_buf then
        anim.bump(from_buf, from[1], from[2], { interval = 15, reverse = true })
    end
    -- Điểm đến: đọc cursor TẠI THỜI ĐIỂM vẽ (chống lệch khi buffer đổi)
    vim.defer_fn(function()
        local cur = vim.api.nvim_win_get_cursor(0)
        anim.bump(vim.api.nvim_get_current_buf(), cur[1], cur[2], { interval = 25 })
    end, 30)
end

function M.setup()
    -- Global mark A..Z
    for i = 0, 25 do
        local m = string.char(65 + i)
        vim.keymap.set("n", "'" .. m, function() bump_jump("'" .. m) end,
            { desc = "Global mark (line) + bump" })
    end

    -- Jumplist back/forward, giữ count (vd 3<C-o>)
    vim.keymap.set("n", "<C-o>", function()
        bump_jump(vim.v.count1 .. vim.keycode("<C-o>"))
    end, { desc = "Jumplist back + bump" })
    vim.keymap.set("n", "<Tab>", function()
        bump_jump(vim.v.count1 .. vim.keycode("<C-i>"))
    end, { desc = "Jumplist forward + bump" })
end

return M
