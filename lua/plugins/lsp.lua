-- ============================================================
--  plugins/lsp.lua
-- ============================================================

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
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
                    ensure_installed = { "gopls" },
                    automatic_installation = true,
                })
            end,
        },
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- 1. Diagnostic UI
        vim.diagnostic.config({
            virtual_text     = false,
            signs            = true,
            underline        = true,
            update_in_insert = false,
            severity_sort    = true,
            float            = {
                border  = "rounded",
                source  = "if_many",
            },
        })

        -- 2. Cấu hình gopls qua API mới vim.lsp.config()
        vim.lsp.config("gopls", {
            capabilities = capabilities,
            settings = {
                gopls = {
                    staticcheck       = true,
                    gofumpt           = true,
                    usePlaceholders   = true,
                    completeUnimported= true,
                    matcher           = "Fuzzy",
                    symbolMatcher     = "Fuzzy",
                    analyses = {
                        unusedparams  = true,
                        shadow        = true,
                        nilness       = true,
                        unusedwrite   = true,
                        useany        = true,
                    },
                    -- ------------------------------------------------------------
                    -- FIX 1: Tối ưu Inlay Hints chuyên biệt cho Gopher
                    -- ------------------------------------------------------------
                    hints = {
                        parameterNames         = true,  -- CHỈ BẬT: Hiện tên tham số hàm (ví dụ: ctx:, req:)
                        assignVariableTypes    = false, -- TẮT: Không hiện kiểu dữ liệu khi gán biến (err: error)
                        compositeLiteralFields = false, -- TẮT: Không hiện tên trường trong struct literal
                        constantValues         = false, -- TẮT: Không hiện giá trị của hằng số iota
                        functionTypeParameters = false, -- TẮT: Không hiện kiểu generic của func
                        rangeVariableTypes     = false, -- TẮT: Không hiện kiểu dữ liệu trong vòng lặp k, v
                    },
                },
            },
        })

        vim.lsp.enable("gopls")

        -- 3. Keymaps + inlay hints qua LspAttach autocmd
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

                -- ---- Các LSP keymaps mặc định của bạn ----
                map("n", "gd",         vim.lsp.buf.definition,      "Goto definition")
                map("n", "gr",         vim.lsp.buf.references,      "List references")
                map("n", "gi",         vim.lsp.buf.implementation,  "Goto implementation")
                map("n", "gt",         vim.lsp.buf.type_definition, "Goto type definition")
                map("n", "K",          vim.lsp.buf.hover,           "Hover doc")
                map("n", "<leader>rn", vim.lsp.buf.rename,          "Rename symbol")
                map("n", "<leader>ca", vim.lsp.buf.code_action,     "Code action")

                -- ------------------------------------------------------------
                -- FIX 2: Map phím Ctrl + Shift + I để tìm Implementation / Reference
                -- Ghostty hỗ trợ giao thức Kitty Keyboard nên tổ hợp này chạy trực tiếp.
                -- ------------------------------------------------------------
                map("n", "<C-S-i>",    vim.lsp.buf.implementation,  "Show Implementation (Ctrl+Shift+I)")
                map("n", "<C-S-r>",    vim.lsp.buf.references,      "Show References (Ctrl+Shift+R)")

                -- Di chuyển giữa các lỗi trong file
                map("n", "[d", function() vim.diagnostic.goto_prev({ float = true }) end, "Prev diagnostic")
                map("n", "]d", function() vim.diagnostic.goto_next({ float = true }) end, "Next diagnostic")
                map("n", "<leader>e", vim.diagnostic.open_float, "Show line diagnostic")

                -- Kích hoạt Inlay Hints
                if client
                   and client:supports_method("textDocument/inlayHint")
                   and vim.lsp.inlay_hint
                then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end,
        })

        -- 4. Auto format + organize imports khi lưu file (.go)
        local go_fmt_grp = vim.api.nvim_create_augroup("GoLspFormat", { clear = true })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group   = go_fmt_grp,
            pattern = "*.go",
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
