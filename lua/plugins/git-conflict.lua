-- ============================================================
--  plugins/git-conflict.lua
-- ============================================================

return {
    "akinsho/git-conflict.nvim",
    version = "*",
    event   = { "BufReadPre", "BufNewFile" },
    config  = function()
        require("git-conflict").setup({
            default_commands   = true,
            default_mappings   = false,
            disable_diagnostics = false,
            list_opener        = "copen",
            highlights = {
                incoming = "DiffAdd",
                current  = "DiffText",
            },
        })

        local grp = vim.api.nvim_create_augroup("GitConflictKeymaps", { clear = true })
        vim.api.nvim_create_autocmd("User", {
            group   = grp,
            pattern = "GitConflictDetected",
            callback = function(args)
                local function map(lhs, rhs, desc)
                    vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
                end

                -- Chọn nội dung giữ lại
                map("<leader>co", "<cmd>GitConflictChooseOurs<CR>",   "Conflict: Choose Ours")
                map("<leader>ct", "<cmd>GitConflictChooseTheirs<CR>", "Conflict: Choose Theirs")
                map("<leader>cb", "<cmd>GitConflictChooseBoth<CR>",   "Conflict: Choose Both")
                map("<leader>c0", "<cmd>GitConflictChooseNone<CR>",   "Conflict: Choose None")

                -- Điều hướng giữa các conflict
                map("]x", "<cmd>GitConflictNextConflict<CR>", "Conflict: Next")
                map("[x", "<cmd>GitConflictPrevConflict<CR>", "Conflict: Prev")

                -- Liệt kê toàn bộ conflict ra quickfix
                map("<leader>cq", "<cmd>GitConflictListQf<CR>", "Conflict: List to Quickfix")
            end,
        })

        -- Dọn keymap khi conflict đã được giải quyết xong
        vim.api.nvim_create_autocmd("User", {
            group   = grp,
            pattern = "GitConflictResolved",
            callback = function(args)
                for _, lhs in ipairs({ "<leader>co", "<leader>ct", "<leader>cb", "<leader>c0", "]x", "[x", "<leader>cq" }) do
                    pcall(vim.keymap.del, "n", lhs, { buffer = args.buf })
                end
            end,
        })
    end,
}
