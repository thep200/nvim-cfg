-- ============================================================
-- plugins/which-key.lua
-- ============================================================
return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    opts = {
        preset = "helix",

        layout = {
            width = { min = 20, max = 50 },
            spacing = 1,
            align = "left",
        },

        win = {
            no_overlap = false,

            row = math.huge,
            col = math.huge,

            width = { min = 30, max = 35 },
            height = { min = 4, max = 20 },

            border = "rounded",
            padding = { 1, 2 },
            zindex = 1000,
        },

        spec = {
            { "<leader>f", group = "Find/File", desc = "Find files, buffers, help, etc." },
            { "<leader>q", group = "Quit/Session", desc = "Quit/Session" },
            { "<leader>s", group = "Split Window", desc = "Split Window" },
            { "<leader>l", group = "LSP/Code", desc = "LSP/Code" },
            { "<leader>c", group = "Close Buffer", desc = "Close Buffer" },
        },
    },
}
