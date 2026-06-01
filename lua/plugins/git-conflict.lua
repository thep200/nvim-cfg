-- ============================================================
--  plugins/git-conflict.lua
--  Hiển thị & giải quyết merge conflict ngay trong editor
-- ============================================================

return {
    "akinsho/git-conflict.nvim",
    version = "*",                                   -- pin theo tag ổn định (main có thể unstable)
    event   = { "BufReadPre", "BufNewFile" },
    config  = function()
        require("git-conflict").setup({
            default_mappings   = false,  -- tự định nghĩa keymap bên dưới cho dễ nhớ
            default_commands   = true,   -- giữ các lệnh :GitConflict*
            disable_diagnostics = false, -- tạm tắt diagnostics khi file đang conflict? -> false: vẫn hiện
            list_opener        = "copen",
            highlights = {
                -- Phải là nhóm có background, nếu không sẽ dùng màu mặc định
                incoming = "DiffAdd",   -- phần "theirs" (nhánh kéo về)
                current  = "DiffText",  -- phần "ours" (nhánh hiện tại)
            },
        })

        -- ============================================================
        -- Keymap (chỉ active trong buffer đang có conflict — gắn qua sự kiện
        -- GitConflictDetected để không chiếm phím ở buffer thường).
        -- Namespace <leader>c* = "Conflict ..."
        -- ============================================================
        local grp = vim.api.nvim_create_augroup("GitConflictKeymaps", { clear = true })

        vim.api.nvim_create_autocmd("User", {
            group   = grp,
            pattern = "GitConflictDetected",
            callback = function(args)
                local function map(lhs, rhs, desc)
                    vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
                end

                -- Chọn nội dung giữ lại
                map("<leader>co", "<cmd>GitConflictChooseOurs<CR>",   "Conflict: Choose Ours (nhánh hiện tại)")
                map("<leader>ct", "<cmd>GitConflictChooseTheirs<CR>", "Conflict: Choose Theirs (nhánh kéo về)")
                map("<leader>cb", "<cmd>GitConflictChooseBoth<CR>",   "Conflict: Choose Both (giữ cả hai)")
                map("<leader>c0", "<cmd>GitConflictChooseNone<CR>",   "Conflict: Choose None (bỏ cả hai)")

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
