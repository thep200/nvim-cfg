-- ============================================================
-- core/autocmds.lua
-- Tự động lưu (Auto-save) & Tự động tải lại (Auto-reload)
-- ============================================================

local api = vim.api

-- Bỏ qua: file không tên, không thể chỉnh sửa, chỉ đọc, buffer hệ thống, không có quyền ghi
local function safe_update()
    local bufname = api.nvim_buf_get_name(0)
    local buf     = vim.bo
    if bufname == "" or not buf.modifiable or buf.readonly or buf.buftype ~= "" then
        return
    end
    if vim.fn.filewritable(bufname) == 0 then
        return
    end
    pcall(vim.cmd, "silent! update")
end

-- Auto-save: chỉ khi rời Insert/cửa sổ/tiêu điểm (tránh I/O dày khi đang gõ)
api.nvim_create_autocmd({ "InsertLeave", "FocusLost", "BufLeave" }, {
    group    = api.nvim_create_augroup("AutoSave", { clear = true }),
    pattern  = "*",
    nested   = true,
    callback = safe_update,
    desc     = "Auto-save khi ngừng gõ, chuyển cửa sổ hoặc mất tiêu điểm",
})

-- Auto-reload: chỉ check khi vào lại cửa sổ/buffer (đủ cho git pull, format ngoài...)
api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    group    = api.nvim_create_augroup("AutoReload", { clear = true }),
    pattern  = "*",
    callback = function()
        local mode = api.nvim_get_mode().mode
        if mode:match("[crRt!]") or vim.fn.getcmdwintype() ~= "" then
            return
        end
        pcall(vim.cmd, "checktime")
    end,
    desc = "Tự động tải lại nội dung nếu file bị thay đổi từ bên ngoài (git pull, etc.)",
})
