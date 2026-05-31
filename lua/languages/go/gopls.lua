-- ============================================================
--  languages/go/gopls.lua
--  Cấu hình LSP cho Go (gopls)
-- ============================================================

return {
    -- Tên server, dùng cho vim.lsp.config(name, ...)
    name = "gopls",

    -- Server cần cài qua mason-lspconfig (ensure_installed)
    mason = { "gopls" },

    -- Settings truyền vào vim.lsp.config("gopls", { settings = ... })
    settings = {
        gopls = {
            staticcheck        = true,
            gofumpt            = true,
            usePlaceholders    = true,
            completeUnimported = true,
            matcher            = "Fuzzy",
            symbolMatcher      = "Fuzzy",
            analyses = {
                unusedparams = true,
                shadow       = true,
                nilness      = true,
                unusedwrite  = true,
                useany       = true,
            },
            hints = {
                parameterNames         = true,
                assignVariableTypes    = false,
                compositeLiteralFields = false,
                constantValues         = false,
                functionTypeParameters = false,
                rangeVariableTypes     = false,
            },
        },
    },

    -- Auto-format & organize imports khi lưu file (BufWritePre)
    format_on_save = {
        pattern          = "*.go",
        organize_imports = true,
    },
}
