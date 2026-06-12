-- ============================================================
-- plugins/markview.lua
-- ============================================================
return {
    "OXY2DEV/markview.nvim",
    ft = "markdown", -- Chỉ load khi mở file markdown
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("markview").setup({})
        vim.keymap.set("n", "<leader>mp", "<cmd>Markview toggle<CR>", { desc = "Toggle Markview" })
    end,
}
