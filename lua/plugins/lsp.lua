-- ============================================================
-- plugins/lsp.lua
-- ============================================================

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        {
            "williamboman/mason.nvim",
            build = ":MasonUpdate",
            opts  = { ui = { border = "rounded" } },
        },
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "nvim-telescope/telescope.nvim",
    },

    config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- ============================================================
        -- 1. Diagnostic UI
        -- ============================================================
        vim.diagnostic.config({
            update_in_insert = false,
            signs            = false,
            underline        = true,
            severity_sort    = true,
            float = {
                border = "rounded",
                source = "if_many",
                header = "",
                prefix = "",
            },
        })

        -- ============================================================
        -- 2. Gopls Settings — phải set BEFORE mason-lspconfig.setup
        --    (mason-lspconfig v2 tự gọi vim.lsp.enable cho server đã install)
        -- ============================================================
        vim.lsp.config("gopls", {
            capabilities = capabilities,
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
        })

        require("mason-lspconfig").setup({ensure_installed = { "gopls" }})

        -- ============================================================
        -- 3. LspAttach (Keymaps & Inlay Hints)
        -- ============================================================
        local lsp_grp = vim.api.nvim_create_augroup("LspKeymaps", { clear = true })

        local lsp_keys = {
            { "n", "gd",         "<cmd>Telescope lsp_definitions<CR>",      "Goto Definition" },
            { "n", "gr",         "<cmd>Telescope lsp_references<CR>",       "List References" },
            { "n", "gi",         "<cmd>Telescope lsp_implementations<CR>",  "Goto Implementation" },
            { "n", "gt",         "<cmd>Telescope lsp_type_definitions<CR>", "Goto Type Definition" },
            { "n", "K",          vim.lsp.buf.hover,                         "Hover Documentation" },
            { "n", "<leader>rn", vim.lsp.buf.rename,                        "Rename Symbol" },
            { "n", "<leader>ca", vim.lsp.buf.code_action,                   "Code Action" },
            { "n", "<leader>gl",  function() vim.diagnostic.open_float({ border = "rounded" }) end, "Line Diagnostics" },
            { "n", "[d",         function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev Diagnostic" },
            { "n", "]d",         function() vim.diagnostic.jump({ count =  1, float = true }) end, "Next Diagnostic" },
        }

        vim.api.nvim_create_autocmd("LspAttach", {
            group = lsp_grp,
            callback = function(args)
                local bufnr  = args.buf
                local client = vim.lsp.get_client_by_id(args.data.client_id)

                for _, k in ipairs(lsp_keys) do
                    vim.keymap.set(k[1], k[2], k[3], { buffer = bufnr, silent = true, noremap = true, desc = k[4] })
                end

                if client and client:supports_method("textDocument/inlayHint") and vim.lsp.inlay_hint then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end,
        })

        -- Dọn buffer-local keymaps khi không còn LSP nào attach vào buffer đó
        vim.api.nvim_create_autocmd("LspDetach", {
            group = lsp_grp,
            callback = function(args)
                local remaining = vim.tbl_filter(function(c)
                    return c.id ~= args.data.client_id
                end, vim.lsp.get_clients({ bufnr = args.buf }))
                if #remaining > 0 then return end

                for _, k in ipairs(lsp_keys) do
                    pcall(vim.keymap.del, k[1], k[2], { buffer = args.buf })
                end
            end,
        })

        -- ============================================================
        -- 4. Auto-Format & Organize Imports on Save
        --    Sync để format chạy đúng thứ tự; timeout 1s để không treo lâu
        -- ============================================================
        vim.api.nvim_create_autocmd("BufWritePre", {
            group    = vim.api.nvim_create_augroup("GoLspFormat", { clear = true }),
            pattern  = "*.go",
            callback = function()
                local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/codeAction" })
                for _, client in ipairs(clients) do
                    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
                    params.context = { only = { "source.organizeImports" }, diagnostics = {} }
                    local result = client:request_sync("textDocument/codeAction", params, 1000, 0)
                    for _, action in ipairs((result or {}).result or {}) do
                        if action.edit then
                            vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                        end
                    end
                end
                vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
            end,
        })
    end,
}
