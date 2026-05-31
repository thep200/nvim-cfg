-- ============================================================
-- core/autocmds.lua
-- Tự động lưu (Auto-save) & Tự động tải lại (Auto-reload)
-- ============================================================

local api = vim.api

-- Auto-save
api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
    group    = api.nvim_create_augroup("AutoSave", { clear = true }),
    pattern  = "*",
    nested   = true,
    callback = function ()
        local bufname = api.nvim_buf_get_name(0)
        local buf     = vim.bo
        if bufname == "" or not buf.modifiable or buf.readonly or buf.buftype ~= "" then
            return
        end
        if vim.fn.filewritable(bufname) == 0 then
            return
        end
        pcall(vim.cmd, "silent! update")
    end,
    desc     = "Auto save when leaving a buffer or losing focus",
})

-- Auto-reload
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
    desc = "Auto reload when entering a buffer or gaining focus",
})
