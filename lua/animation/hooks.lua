-- ============================================================
--  lua/animation/hooks.lua
--  Gắn hiệu ứng bump vào các motion ngoài flash.
--  Hiện tại: GLOBAL mark jump (`A..`Z, 'A..'Z — nhảy xuyên file).
--  Mark thường a-z và các mark đặc biệt giữ nguyên native.
-- ============================================================

local M = {}

local function mark_jump(key, mark)
    return function()
        local anim = require("animation.bump")
        local from_buf = vim.api.nvim_get_current_buf()
        local from = vim.api.nvim_win_get_cursor(0)

        local ok, err = pcall(vim.cmd, "normal! " .. key .. mark)
        if not ok then
            -- Mark chưa đặt: báo lỗi như native (E20), không bump
            vim.api.nvim_echo({ { err:match("E%d+:[^\n]*") or err, "ErrorMsg" } }, false, {})
            return
        end

        -- Điểm xuất phát: vòng co vào tâm, chỉ vẽ khi chưa chuyển file khác
        if vim.api.nvim_get_current_buf() == from_buf then
            anim.bump(from_buf, from[1], from[2], { interval = 15, reverse = true })
        end
        -- Điểm đến: đọc cursor TẠI THỜI ĐIỂM vẽ (chống lệch khi buffer đổi)
        vim.defer_fn(function()
            local cur = vim.api.nvim_win_get_cursor(0)
            anim.bump(vim.api.nvim_get_current_buf(), cur[1], cur[2], { interval = 25 })
        end, 30)
    end
end

function M.setup()
    for i = 0, 25 do
        local m = string.char(65 + i) -- A..Z
        vim.keymap.set("n", "'" .. m, mark_jump("'", m), { desc = "Global mark (line) + bump" })
    end
end

return M
