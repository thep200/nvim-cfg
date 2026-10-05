-- ============================================================
-- plugins/lsp.lua
-- LSP client (generic). Cấu hình riêng từng ngôn ngữ nằm ở
-- lua/languages/<lang>/*.lua và được nạp qua registry `languages`.
-- ============================================================

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        {
            "mason-org/mason.nvim",
            version = "^2.0.0",
            opts    = { ui = { border = "rounded" } },
        },
        {
            "mason-org/mason-lspconfig.nvim",
            version = "^2.0.0",
        },
        "nvim-telescope/telescope.nvim",
    },

    config = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        if ok then
            capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
        end

        local lsp_langs = require("languages").lsp()

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
        -- 2. Đăng ký server cho từng ngôn ngữ đã bật
        -- ============================================================
        for _, cfg in ipairs(lsp_langs) do
            local markers = cfg.root_markers or { ".git" }
            vim.lsp.config(cfg.name, {
                capabilities = capabilities,
                settings     = cfg.settings,
                root_dir = function(bufnr, on_dir)
                    local fname = vim.api.nvim_buf_get_name(bufnr)
                    if fname:match("^%a[%w+.%-]*://") then
                        return
                    end
                    local root = vim.fs.root(bufnr, markers)
                    on_dir(root or (fname ~= "" and vim.fn.fnamemodify(fname, ":h")) or vim.fn.getcwd())
                end,
            })
        end

        require("mason-lspconfig").setup({
            ensure_installed = require("languages").mason_lsp_servers(),
        })

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
            { "n", "<leader>gl", function() vim.diagnostic.open_float({ border = "rounded" }) end, "Line Diagnostics" },
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
        -- Mọi write (:w tay lẫn auto-save FocusLost/BufLeave) đều ghi file
        -- ngay rồi format NGẦM qua BufWritePost: organize imports -> format
        -- -> tự :update lại nếu có thay đổi. Không còn bước đồng bộ nào
        -- block UI nên rời focus không bị giật.
        -- ============================================================
        local fmt_grp = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

        -- Organize imports + format bất đồng bộ, gọi on_done() khi hoàn tất
        local function organize_and_format_async(bufnr, cfg, on_done)
            local client = vim.lsp.get_clients({ bufnr = bufnr, name = cfg.name })[1]
            if not client then return on_done() end

            -- Dựng params trong ngữ cảnh đúng buffer (có thể đã rời focus)
            local fmt_params, ca_params
            vim.api.nvim_buf_call(bufnr, function()
                fmt_params = vim.lsp.util.make_formatting_params({})
                ca_params  = vim.lsp.util.make_range_params(0, client.offset_encoding)
            end)

            local function do_format()
                if not vim.api.nvim_buf_is_valid(bufnr) then return on_done() end
                client:request("textDocument/formatting", fmt_params, function(_, result)
                    if result and vim.api.nvim_buf_is_valid(bufnr) then
                        vim.lsp.util.apply_text_edits(result, bufnr, client.offset_encoding)
                    end
                    on_done()
                end, bufnr)
            end

            if cfg.format_on_save.organize_imports then
                ca_params.context = { only = { "source.organizeImports" }, diagnostics = {} }
                client:request("textDocument/codeAction", ca_params, function(_, actions)
                    for _, action in ipairs(actions or {}) do
                        if action.edit and vim.api.nvim_buf_is_valid(bufnr) then
                            vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                        end
                    end
                    do_format()
                end, bufnr)
            else
                do_format()
            end
        end

        for _, cfg in ipairs(lsp_langs) do
            local fos = cfg.format_on_save
            if fos then
                vim.api.nvim_create_autocmd("BufWritePost", {
                    group    = fmt_grp,
                    pattern  = fos.pattern,
                    callback = function(args)
                        local buf = args.buf
                        -- Đang trong pipeline format (kể cả lần :update lại) thì bỏ qua
                        if vim.b[buf].fmt_inflight then return end

                        vim.b[buf].fmt_inflight = true
                        organize_and_format_async(buf, cfg, function()
                            if not vim.api.nvim_buf_is_valid(buf) then return end
                            if vim.bo[buf].modified then
                                vim.api.nvim_buf_call(buf, function()
                                    pcall(vim.cmd, "silent! update")
                                end)
                            end
                            vim.b[buf].fmt_inflight = false
                        end)
                    end,
                })
            end
        end
    end,
}
