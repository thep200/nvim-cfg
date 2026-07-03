-- ============================================================
--  plugins/git-conflict.lua
-- ============================================================

return {
    "akinsho/git-conflict.nvim",
    version = "*",
    -- event   = { "BufReadPre", "BufNewFile" },
    lazy = false,
    config  = function()
        require("git-conflict").setup({
            default_commands    = true,
            disable_diagnostics = false,
            list_opener         = "copen",
            highlights = {
                incoming = "DiffAdd",
                current  = "DiffText",
            },

            default_mappings = {
                ours   = "<leader>co",
                theirs = "<leader>ct",
                both   = "<leader>cb",
                none   = "<leader>c0",
                next   = "]x",
                prev   = "[x",
            },
        })

        -- Lệnh List ra Quickfix là lệnh global nên ta set bên ngoài bình thường
        vim.keymap.set("n", "<leader>cq", "<cmd>GitConflictListQf<CR>", { desc = "Conflict: List to Quickfix" })
    end,
}
