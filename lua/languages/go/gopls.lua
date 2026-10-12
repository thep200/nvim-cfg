-- ============================================================
--  languages/go/gopls.lua
-- ============================================================

-- GOMODCACHE + GOROOT, hỏi `go env` 1 lần rồi cache
local shared_dirs_cache
local function shared_dirs()
    if not shared_dirs_cache then
        local res = vim.system({ "go", "env", "GOMODCACHE", "GOROOT" }, { text = true }):wait()
        shared_dirs_cache = res.code == 0 and vim.split(vim.trim(res.stdout), "\n") or {}
    end
    return shared_dirs_cache
end

return {
    -- Tên server, dùng cho vim.lsp.config(name, ...)
    name = "gopls",

    -- Server cần cài qua mason-lspconfig (ensure_installed)
    mason = { "gopls" },

    -- Marker để xác định root của workspace (ưu tiên từ trên xuống)
    root_markers = { "go.work", "go.mod", ".git" },

    -- Thư mục thư viện: file trong đây dùng chung gopls của project
    shared_dirs = shared_dirs,

    -- Settings truyền vào vim.lsp.config("gopls", { settings = ... })
    settings = {
        gopls = {
            buildFlags         = { "-tags=integration,wireinject,debug,dev,debugwire,debugtest" },
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

    -- Auto-format & organize imports khi lưu file (BufWritePost, chạy ngầm)
    format_on_save = {
        pattern          = "*.go",
        organize_imports = true,
    },
}
