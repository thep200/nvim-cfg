-- ============================================================
--  plugins/indent-blankline.lua
--  Hiển thị đường indent guide (virtual text, không dùng conceal)
-- ============================================================

return {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    opts  = {
        indent = {
            char         = "┊", -- ╎
            tab_char     = "┊",
            highlight    = "IblIndent",
        },
        scope = {
            enabled    = true,
            char       = "┊",
            show_start = false,
            show_end   = false,
            highlight  = "IblScope",
        },
        exclude = {
            filetypes = {
                "help", "neo-tree", "Telescope", "TelescopePrompt",
                "lazy", "mason", "dashboard", "alpha",
                "gitcommit", "gitrebase",
                "dap-repl", "dapui_scopes", "dapui_breakpoints",
                "dapui_stacks", "dapui_watches", "dapui_console",
            },
            buftypes = { "terminal", "nofile", "quickfix", "prompt" },
        },
    },
}
