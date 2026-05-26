-- ============================================================
--  core/autocmds.lua
--  Port từ phần auto-save & auto-reload trong editor.vim
-- ============================================================

local api = vim.api

-- ============================================================
--  Auto-save
--
--  Trigger ở 3 thời điểm "tự nhiên" (không hammer disk):
--    1. InsertLeave - khi rời insert mode (vừa gõ xong)
--    2. FocusLost   - khi vim mất focus (chuyển app khác)
--    3. BufLeave    - khi chuyển sang buffer khác
--
--  Để tắt: thêm `vim.g.disable_autosave = true` vào init.lua
--  hoặc xoá augroup này.
-- ============================================================
local function safe_update()
    local bufname = api.nvim_buf_get_name(0)
    local buf     = vim.bo
    -- Bỏ qua nếu: buffer chưa có tên, không sửa được, readonly, hoặc buftype khác rỗng
    -- (vd: terminal, help, quickfix... đều có buftype != "")
    if bufname == "" or not buf.modifiable or buf.readonly or buf.buftype ~= "" then
        return
    end
    -- pcall để bất kỳ lỗi nào (vd: permission) cũng không phá flow
    pcall(vim.cmd, "silent! update")
end

local autosave = api.nvim_create_augroup("AutoSave", { clear = true })
api.nvim_create_autocmd({ "InsertLeave", "FocusLost", "BufLeave" }, {
    group    = autosave,
    pattern  = "*",
    callback = safe_update,
    desc     = "Auto-save buffer khi rời insert / mất focus / chuyển buffer",
})

-- ============================================================
--  Auto-reload
--
--  Khi vim focus trở lại / quay lại buffer, kiểm tra xem file
--  có bị thay đổi từ bên ngoài (vd: git pull, formatter).
--  (Yêu cầu vim.opt.autoread = true - đã set ở options.lua)
-- ============================================================
local autoreload = api.nvim_create_augroup("AutoReload", { clear = true })
api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group    = autoreload,
    pattern  = "*",
    callback = function()
        -- Không checktime khi đang trong cmdline / replace / shell / terminal mode
        -- (giống điều kiện mode() !~# '(c|r.?|!|t)' bản Vim cũ)
        local mode = api.nvim_get_mode().mode
        if mode:match("[crRt!]") then return end
        if vim.fn.getcmdwintype() ~= "" then return end
        pcall(vim.cmd, "checktime")
    end,
    desc = "Reload file nếu bị thay đổi từ bên ngoài",
})
