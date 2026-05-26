-- ============================================================
--  plugins/lsp.lua
--  Thay thế: prabirshrestha/vim-lsp + mattn/vim-lsp-settings
--
--  Stack mới (Neovim 0.11+ native LSP API):
--    - mason.nvim          : quản lý cài đặt LSP server binary
--                            (tương đương vim-lsp-settings cũ)
--    - mason-lspconfig     : cài tự động gopls qua Mason
--    - nvim-lspconfig      : cung cấp default config cho gopls
--                            (cmd, filetypes, root_markers)
--    - vim.lsp.config()    : API MỚI của Neovim 0.11+ thay cho
--                            require("lspconfig").xxx.setup({...})
--                            (xem :help lspconfig-nvim-0.11)
--
--  Toàn bộ gopls settings (staticcheck, gofumpt, analyses, hints,...)
--  + LSP keymaps + auto format on save -> giữ NGUYÊN từ lsp.vim cũ.
-- ============================================================

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        -- ---- Mason: cài đặt LSP server tự động ----
        {
            "williamboman/mason.nvim",
            build  = ":MasonUpdate",
            config = function()
                require("mason").setup({
                    ui = { border = "rounded" },
                })
            end,
        },
        {
            "williamboman/mason-lspconfig.nvim",
            config = function()
                require("mason-lspconfig").setup({
                    -- ---- Tự động cài server khi mở Neovim lần đầu ----
                    ensure_installed = {
                        "gopls",          -- Go language server
                        -- Có thể thêm:
                        -- "lua_ls",      -- nếu muốn LSP cho config Neovim
                    },
                    -- KHÔNG để mason-lspconfig tự setup() server vì ta dùng
                    -- vim.lsp.config + vim.lsp.enable bên dưới (API 0.11+).
                    automatic_installation = true,
                })
            end,
        },

        -- ---- Bridge với cmp để gợi ý LSP ----
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- ============================================================
        -- 1. Diagnostic UI - port từ g:lsp_diagnostics_* cũ
        -- ============================================================
        vim.diagnostic.config({
            virtual_text     = false,    -- tắt virtual text (giống lsp_diagnostics_virtual_text_enabled = 0)
            signs            = true,     -- giữ sign column +/!/i/?
            underline        = true,
            update_in_insert = false,    -- không update khi đang gõ (đỡ nhiễu)
            severity_sort    = true,
            float            = {
                border  = "rounded",
                source  = "if_many",     -- chỉ hiện tên LSP khi có nhiều source
            },
        })

        -- ============================================================
        -- 2. Cấu hình gopls qua API mới vim.lsp.config()
        --    Port NGUYÊN settings từ g:lsp_settings.gopls cũ.
        --
        --    nvim-lspconfig v2+ cung cấp sẵn cmd/filetypes/root_markers
        --    cho gopls, ta chỉ cần override capabilities + settings.
        -- ============================================================
        vim.lsp.config("gopls", {
            capabilities = capabilities,
            settings = {
                gopls = {
                    -- ---- Static analysis ----
                    staticcheck       = true,
                    gofumpt           = true,
                    usePlaceholders   = true,
                    completeUnimported= true,

                    -- ---- Matcher ----
                    matcher           = "Fuzzy",
                    symbolMatcher     = "Fuzzy",

                    -- ---- Analyses (giữ nguyên list cũ) ----
                    analyses = {
                        unusedparams  = true,
                        shadow        = true,
                        nilness       = true,
                        unusedwrite   = true,
                        useany        = true,
                    },

                    -- ---- Inlay hints (giữ nguyên list cũ) ----
                    hints = {
                        assignVariableTypes    = true,
                        compositeLiteralFields = true,
                        constantValues         = true,
                        functionTypeParameters = true,
                        parameterNames         = true,
                        rangeVariableTypes     = true,
                    },
                },
            },
        })

        -- Bật gopls - server sẽ tự attach vào buffer có filetype match
        vim.lsp.enable("gopls")

        -- ============================================================
        -- 3. Keymaps + inlay hints qua LspAttach autocmd
        --    (pattern khuyến nghị bởi Neovim docs cho API mới)
        -- ============================================================
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
            callback = function(args)
                local bufnr  = args.buf
                local client = vim.lsp.get_client_by_id(args.data.client_id)

                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, {
                        buffer = bufnr,
                        silent = true,
                        noremap = true,
                        desc = desc,
                    })
                end

                -- ---- LSP keymaps (giữ NGUYÊN từ lsp.vim) ----
                map("n", "gd",         vim.lsp.buf.definition,      "Goto definition")
                map("n", "gr",         vim.lsp.buf.references,      "List references")
                map("n", "gi",         vim.lsp.buf.implementation,  "Goto implementation")
                map("n", "gt",         vim.lsp.buf.type_definition, "Goto type definition")
                map("n", "K",          vim.lsp.buf.hover,           "Hover doc")
                map("n", "<leader>rn", vim.lsp.buf.rename,          "Rename symbol")
                map("n", "<leader>ca", vim.lsp.buf.code_action,     "Code action")

                -- Nhảy giữa diagnostics (port [d / ]d cũ)
                map("n", "[d", function() vim.diagnostic.goto_prev({ float = true }) end, "Prev diagnostic")
                map("n", "]d", function() vim.diagnostic.goto_next({ float = true }) end, "Next diagnostic")

                -- Bonus: hiện diagnostic của dòng hiện tại trong float
                map("n", "<leader>e", vim.diagnostic.open_float, "Show line diagnostic")

                -- ---- Bật inlay hints (Neovim 0.10+) ----
                -- Tương đương g:lsp_settings.gopls.hints.* cũ
                --
                -- Lưu ý: Neovim 0.12+ deprecated client.supports_method(...) (dot),
                -- thay bằng client:supports_method(...) (method call - colon).
                -- Feature cũ sẽ bị xoá ở Nvim 0.13.
                if client
                   and client:supports_method("textDocument/inlayHint")
                   and vim.lsp.inlay_hint
                then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end,
        })

        -- ============================================================
        -- 4. Auto format + organize imports khi save file .go
        --    Port từ augroup lsp_go_on_save cũ.
        --
        --    Lưu ý: gopls dùng offset_encoding = "utf-16" (mặc định LSP spec).
        --    Hardcode "utf-16" an toàn cho gopls và ổn định giữa các version
        --    Neovim (0.10 / 0.11+).
        -- ============================================================
        local go_fmt_grp = vim.api.nvim_create_augroup("GoLspFormat", { clear = true })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group   = go_fmt_grp,
            pattern = "*.go",
            callback = function()
                -- 1. Organize imports thông qua LSP code action SYNC
                --    (gopls action: "source.organizeImports" - giống vim-lsp cũ)
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

                -- 2. Format toàn file (gofumpt do gopls handle, đã bật ở settings trên)
                vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
            end,
        })
    end,
}
