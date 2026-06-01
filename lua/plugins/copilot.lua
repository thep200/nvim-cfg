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
                    accept      = false,
                    accept_word = false,
                    next        = "<M-]>",
                    prev        = "<M-[>",
                    dismiss     = "<C-]>",
                },
            },
            filetypes = {
                ["*"]           = true,
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
