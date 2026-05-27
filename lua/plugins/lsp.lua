-- ============================================================
-- plugins/lsp.lua
-- ============================================================

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        {
            "williamboman/mason.nvim",
            build  = ":MasonUpdate",
            config = function()
                require("mason").setup({ ui = { border = "rounded" } })
            end,
        },
        {
            "williamboman/mason-lspconfig.nvim",
            config = function()
                require("mason-lspconfig").setup({
                    ensure_installed       = { "gopls" },
                    automatic_installation = true,
                })
            end,
        },
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
            -- virtual_text     = {
            --     spacing  = 2,
            --     prefix   = "",
            --     source   = "if_many",
            --     severity = { min = vim.diagnostic.severity.INFO },
            --     format   = function(diagnostic)
            --         local msg = diagnostic.message
            --         if #msg > 80 then msg = msg:sub(1, 77) .. "..." end
            --         return msg
            --     end,
            -- },
            float = {
                border = "rounded",
                source = "if_many",
                header = "",
                prefix = "",
            },
        })

        -- ============================================================
        -- 2. Gopls Settings
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

        vim.lsp.enable("gopls")

        -- ============================================================
        -- 3. LspAttach (Keymaps & Inlay Hints)
        -- ============================================================
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
            callback = function(args)
                local bufnr  = args.buf
                local client = vim.lsp.get_client_by_id(args.data.client_id)

                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
                end

                -- Telescope Pickers
                map("n", "gd",      "<cmd>Telescope lsp_definitions<CR>",      "Goto Definition")
                map("n", "gr",      "<cmd>Telescope lsp_references<CR>",       "List References")
                map("n", "gi",      "<cmd>Telescope lsp_implementations<CR>",  "Goto Implementation")
                map("n", "gt",      "<cmd>Telescope lsp_type_definitions<CR>", "Goto Type Definition")

                -- Actions & Hover
                map("n", "K",          vim.lsp.buf.hover,       "Hover Documentation")
                map("n", "<leader>rn", vim.lsp.buf.rename,      "Rename Symbol")
                map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

                -- Diagnostics Navigation
                map("n", "[d",        function() vim.diagnostic.goto_prev({ float = true }) end, "Previous Diagnostic")
                map("n", "]d",        function() vim.diagnostic.goto_next({ float = true }) end, "Next Diagnostic")
                map("n", "<leader>e", vim.diagnostic.open_float, "Show Line Diagnostic")

                -- Enable Inlay Hints
                if client and client:supports_method("textDocument/inlayHint") and vim.lsp.inlay_hint then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end,
        })

        -- ============================================================
        -- 4. Auto-Format & Organize Imports on Save
        -- ============================================================
        local go_fmt_grp = vim.api.nvim_create_augroup("GoLspFormat", { clear = true })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group    = go_fmt_grp,
            pattern  = "*.go",
            callback = function()
                local params = vim.lsp.util.make_range_params(nil, "utf-16")
                params.context = { only = { "source.organizeImports" }, diagnostics = {} }

                local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
                for _, res in pairs(result or {}) do
                    for _, action in pairs(res.result or {}) do
                        if action.edit then
                            vim.lsp.util.apply_workspace_edit(action.edit, "utf-16")
                        elseif type(action.command) == "table" then
                            vim.lsp.buf.execute_command(action.command)
                        end
                    end
                end

                vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
            end,
        })
    end,
}
