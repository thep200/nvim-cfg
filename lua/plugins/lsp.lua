-- ============================================================
--  plugins/lsp.lua
--  LSP cho Go (gopls) với staticcheck + analyses đầy đủ.
--
--  Stack:
--    - mason.nvim          : auto-install LSP binary
--    - mason-lspconfig     : kết nối Mason <-> nvim-lspconfig
--    - nvim-lspconfig      : recipe sẵn cho gopls
--    - cmp-nvim-lsp        : capabilities cho autocomplete
--    - telescope.nvim      : popup picker cho gd/gr/gi/gt
--
--  Diagnostic hiển thị:
--    - Inline cuối dòng (virtual_text) với prefix "●"
--    - Sign ✗/!/i/? ở signcolumn
--    - Underline + undercurl ngay dưới code lỗi
--    - Hover (K) hoặc <leader>e để xem chi tiết
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
                    ensure_installed       = { "gopls" },
                    automatic_installation = true,
                })
            end,
        },
        "hrsh7th/cmp-nvim-lsp",
        -- Đảm bảo Telescope load trước/cùng LSP để các lệnh :Telescope lsp_*
        -- dùng được trong LspAttach.
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- ============================================================
        -- 1. Diagnostic UI - hiển thị nhất quán, không bỏ sót warning
        --
        -- THAY ĐỔI QUAN TRỌNG so với trước:
        --   - virtual_text = TRUE: warning hiện inline cuối dòng -> không
        --     còn phải nheo mắt nhìn signcolumn.
        --   - update_in_insert = FALSE: không spam diagnostic khi đang gõ
        --     nửa chừng identifier. Esc xong là warning hiện liền.
        -- ============================================================
        vim.diagnostic.config({
            virtual_text     = {
                spacing  = 2,
                prefix   = "",
                source   = "if_many", -- show source khi có >1 LSP
                severity = { min = vim.diagnostic.severity.INFO },
                format = function(diagnostic)
                    local msg = diagnostic.message
                    if #msg > 80 then
                        msg = msg:sub(1, 77) .. "..."
                    end
                    return msg
                end,
            },
            update_in_insert = false,
            signs            = true,
            underline        = true,
            severity_sort    = true,
            float            = {
                border = "rounded",
                source = "if_many",
                header = "",
                prefix = "",
            },
        })

        -- ============================================================
        -- 2. Cấu hình gopls qua API mới vim.lsp.config() (Neovim 0.11+)
        --
        -- staticcheck = true bật toàn bộ analysers SA* của staticcheck
        -- (https://staticcheck.dev/docs/checks/). Đây là tất cả những gì
        -- cần để có warning kiểu "SA1006: Printf format mismatch", v.v.
        --
        -- analyses = {...} bật các analyser nội bộ gopls không thuộc
        -- staticcheck (unusedparams, shadow, nilness, ...).
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

                    -- ---- Analysers bổ sung (ngoài staticcheck) ----
                    analyses           = {
                        unusedparams = true, -- tham số hàm không dùng
                        shadow       = true, -- biến shadow biến khác
                        nilness      = true, -- dereference nil
                        unusedwrite  = true, -- ghi biến rồi không đọc
                        useany       = true, -- gợi ý dùng `any` thay `interface{}`
                    },

                    -- ---- Inlay Hints chuyên biệt cho Go ----
                    -- Chỉ bật phần thực sự hữu ích, tránh nhiễu mắt
                    hints              = {
                        parameterNames         = true, -- tên tham số khi gọi hàm
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
        -- 3. Keymaps + Inlay Hints (đăng ký qua LspAttach autocmd)
        -- ============================================================
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
            callback = function(args)
                local bufnr  = args.buf
                local client = vim.lsp.get_client_by_id(args.data.client_id)

                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, {
                        buffer  = bufnr,
                        silent  = true,
                        noremap = true,
                        desc    = desc,
                    })
                end

                -- ------------------------------------------------------------
                -- Navigation: Telescope popup (auto-jump nếu chỉ có 1 kết quả)
                -- ------------------------------------------------------------
                map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Goto definition (popup)")
                map("n", "gr", "<cmd>Telescope lsp_references<CR>", "List references (popup)")
                map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", "Goto implementation (popup)")
                map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", "Goto type definition (popup)")

                -- Hover doc (không phải list -> giữ native float)
                map("n", "K", vim.lsp.buf.hover, "Hover doc")

                -- Rename / Code action
                map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")

                -- ------------------------------------------------------------
                -- Ctrl+Shift+I / R: shortcut nhanh cho References / Implementation
                -- (Ghostty hỗ trợ Kitty Keyboard Protocol nên combo này pass-through)
                -- ------------------------------------------------------------
                map("n", "<C-S-i>", "<cmd>Telescope lsp_implementations<CR>", "Show Implementation (popup)")
                map("n", "<C-S-r>", "<cmd>Telescope lsp_references<CR>", "Show References (popup)")

                -- ------------------------------------------------------------
                -- Diagnostics navigation
                -- ------------------------------------------------------------
                map("n", "[d", function() vim.diagnostic.goto_prev({ float = true }) end, "Prev diagnostic")
                map("n", "]d", function() vim.diagnostic.goto_next({ float = true }) end, "Next diagnostic")
                map("n", "<leader>e", vim.diagnostic.open_float, "Show line diagnostic")

                -- ------------------------------------------------------------
                -- Kích hoạt Inlay Hints (nếu LSP server support)
                -- ------------------------------------------------------------
                if client
                    and client:supports_method("textDocument/inlayHint")
                    and vim.lsp.inlay_hint
                then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end,
        })

        -- ============================================================
        -- 4. Auto format + organize imports khi lưu file (.go)
        --
        -- Trigger trên BufWritePre. Auto-save trong autocmds.lua phải set
        -- nested = true thì block này mới fire (xem comment ở autocmds.lua).
        -- ============================================================
        local go_fmt_grp = vim.api.nvim_create_augroup("GoLspFormat", { clear = true })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group    = go_fmt_grp,
            pattern  = "*.go",
            callback = function()
                -- ---- Step 1: organize imports (goimports) ----
                local params = vim.lsp.util.make_range_params(nil, "utf-16")
                params.context = {
                    only        = { "source.organizeImports" },
                    diagnostics = {},
                }

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

                -- ---- Step 2: format file (gofumpt) ----
                vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
            end,
        })
    end,
}
