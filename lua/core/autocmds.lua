-- ============================================================
-- core/autocmds.lua
-- Tự động lưu (Auto-save) & Tự động tải lại (Auto-reload)
-- ============================================================

local api = vim.api

-- ============================================================
-- 1. Hàm An Toàn: Chỉ lưu những file hợp lệ
-- ============================================================
local function safe_update()
    local bufname = api.nvim_buf_get_name(0)
    local buf = vim.bo

    -- Bỏ qua: file không tên, không thể chỉnh sửa, chỉ đọc, hoặc các bộ đệm hệ thống (UI)
    if bufname == "" or not buf.modifiable or buf.readonly or buf.buftype ~= "" then
        return
    end

    -- Bỏ qua: Nếu file không có quyền ghi (Permission denied)
    if vim.fn.filewritable(bufname) == 0 then
        return
    end

    -- Lưu ngầm (Chỉ lưu nếu file có sự thay đổi thực sự để tiết kiệm I/O)
    pcall(vim.cmd, "silent! update")
end

-- ============================================================
-- 2. Kích hoạt Auto-save
-- ============================================================
local autosave = api.nvim_create_augroup("AutoSave", { clear = true })

api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost", "BufLeave" }, {
    group    = autosave,
    pattern  = "*",
    nested   = true,
    callback = safe_update,
    desc     = "Tự động lưu file khi ngừng gõ, chuyển cửa sổ hoặc mất tiêu điểm",
})

-- ============================================================
-- 3. Kích hoạt Auto-reload (Khi file bị sửa từ bên ngoài)
-- ============================================================
local autoreload = api.nvim_create_augroup("AutoReload", { clear = true })

api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group    = autoreload,
    pattern  = "*",
    callback = function()
        local mode = api.nvim_get_mode().mode

        -- Không reload nếu đang ở chế độ gõ lệnh (Command) hoặc bảng tìm kiếm thay thế (Replace)
        if mode:match("[crRt!]") or vim.fn.getcmdwintype() ~= "" then
            return
        end

        -- Kích hoạt lệnh kiểm tra thay đổi hệ thống của Neovim
        pcall(vim.cmd, "checktime")
    end,
    desc = "Tự động tải lại nội dung nếu file bị thay đổi từ bên ngoài (git pull, etc.)",
})
