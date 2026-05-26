-- ============================================================
--  core/autocmds.lua
--  Auto-save & auto-reload buffer.
-- ============================================================

local api = vim.api

-- ============================================================
--  Helper: chỉ save khi buffer thực sự là file edit được
-- ============================================================
local function safe_update()
    local bufname = api.nvim_buf_get_name(0)
    local buf     = vim.bo

    -- Bỏ qua các trường hợp KHÔNG nên save:
    --   - buffer chưa có tên (chưa :w bao giờ)
    --   - buffer không sửa được (vd: help, man)
    --   - buffer readonly
    --   - buffer đặc biệt: terminal, quickfix, neo-tree, telescope...
    if bufname == "" or not buf.modifiable or buf.readonly or buf.buftype ~= "" then
        return
    end

    -- Bỏ qua nếu file không ghi được (vd: permission)
    if vim.fn.filewritable(bufname) == 0 then
        return
    end

    -- update = chỉ write nếu buffer đã modify (tiết kiệm I/O so với :w)
    pcall(vim.cmd, "silent! update")
end

-- ============================================================
--  Auto-save
--
--  Trigger ở 4 thời điểm "tự nhiên":
--    1. InsertLeave - khi rời insert mode (vừa gõ xong text)
--    2. TextChanged - khi sửa text trong NORMAL mode (dd, p, x, ...)
--    3. FocusLost   - khi Neovim mất focus (chuyển sang app khác)
--    4. BufLeave    - khi chuyển sang buffer khác
--
--  ⚠️ QUAN TRỌNG: nested = true cho phép autocmd này trigger các
--  autocmd khác (đặc biệt là BufWritePre của LSP để chạy auto-import
--  + gofumpt). Không có nested = true, :update trong callback sẽ
--  KHÔNG fire BufWritePre (default behavior chống infinite loop).
--  Xem :h autocmd-nested
-- ============================================================
local autosave = api.nvim_create_augroup("AutoSave", { clear = true })

api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost", "BufLeave" }, {
    group    = autosave,
    pattern  = "*",
    nested   = true,
    callback = safe_update,
    desc     = "Auto-save buffer khi rời insert / sửa trong normal / mất focus / chuyển buffer",
})

-- ============================================================
--  Auto-reload
--
--  Khi Neovim focus trở lại / quay lại buffer, kiểm tra xem file
--  có bị thay đổi từ bên ngoài (vd: git pull, formatter chạy ngoài).
--  Yêu cầu vim.opt.autoread = true (đã set ở options.lua)
-- ============================================================
local autoreload = api.nvim_create_augroup("AutoReload", { clear = true })

api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group    = autoreload,
    pattern  = "*",
    callback = function()
        local mode = api.nvim_get_mode().mode
        if mode:match("[crRt!]") then return end
        if vim.fn.getcmdwintype() ~= "" then return end
        pcall(vim.cmd, "checktime")
    end,
    desc = "Reload file nếu bị thay đổi từ bên ngoài",
})
