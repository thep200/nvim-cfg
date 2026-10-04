-- ============================================================
-- core/autocmds.lua
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
        if not buf.modified then
            return
        end
        -- Đánh dấu autosave để lsp.lua bỏ qua format đồng bộ (tránh giật),
        -- write xong bắn User AutoSaved cho lsp.lua format ngầm.
        local bufnr = api.nvim_get_current_buf()
        vim.b[bufnr].autosaving = true
        pcall(vim.cmd, "silent! update")
        vim.b[bufnr].autosaving = false
        api.nvim_exec_autocmds("User", { pattern = "AutoSaved", data = { buf = bufnr } })
    end,
    desc = "Auto save when leaving a buffer or losing focus",
})

-- Auto-reload (bắt cả khi forgecode sửa file từ terminal nhúng)
api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave", "TermClose" }, {
    group    = api.nvim_create_augroup("AutoReload", { clear = true }),
    pattern  = "*",
    callback = function()
        local mode = api.nvim_get_mode().mode
        if mode:match("[crRt!]") or vim.fn.getcmdwintype() ~= "" then
            return
        end
        pcall(vim.cmd, "checktime")
    end,
    desc = "Auto reload when file changes on disk",
})

-- Filetype cho Buf config (buf_ls hỗ trợ lint/completion các file này)
vim.filetype.add({
    filename = {
        ["buf.yaml"]        = "buf-config",
        ["buf.gen.yaml"]    = "buf-config",
        ["buf.work.yaml"]   = "buf-config",
        ["buf.policy.yaml"] = "buf-config",
        ["buf.lock"]        = "buf-config",
    },
})
vim.treesitter.language.register("yaml", "buf-config")

-- Báo khi file bị đổi từ bên ngoài
api.nvim_create_autocmd("FileChangedShellPost", {
    group    = api.nvim_create_augroup("AutoReloadNotify", { clear = true }),
    pattern  = "*",
    callback = function() vim.notify("File changed on disk", vim.log.levels.INFO) end,
    desc = "Notify on external file change",
})
