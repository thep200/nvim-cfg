-- ============================================================
-- plugins/copilot.lua
-- ============================================================

return {
    "zbirenbaum/copilot.lua",
    cmd   = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            panel = { enabled = false },
            suggestion = {
                enabled                = true,
                auto_trigger           = true,
                hide_during_completion = false,
                keymap = {
                    accept      = "<C-j>",
                    accept_word = "<C-l>",
                    accept_line = false,
                    next        = "<M-]>",
                    prev        = "<M-[>",
                    dismiss     = "<C-]>",
                },
            },
            filetypes = {
                ["*"] = function()
                    local name = vim.fs.basename(vim.api.nvim_buf_get_name(0)):lower()
                    if name:match("^%.env") or name:match("secret") or name:match("credential") or name:match("%.pem$") or name:match("%.key$") then
                        return false
                    end
                    return true
                end,
                gitcommit       = false,
                TelescopePrompt = false,
            },
        })

        -- Phím backup khi cmp lỗi/tắt
        local sug = require("copilot.suggestion")
        vim.keymap.set("i", "<C-j>", sug.accept,      { desc = "Copilot: Accept" })
        vim.keymap.set("i", "<C-l>", sug.accept_word, { desc = "Copilot: Accept Word" })
    end,
}
