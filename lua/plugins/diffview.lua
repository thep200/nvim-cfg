-- ============================================================
--  plugins/diffview.lua
--  Giao diện 1 tabpage để xem diff toàn bộ file thay đổi,
--  duyệt lịch sử file/commit, và giải quyết merge conflict.
-- ============================================================
--  Ghi chú: repo gốc "sindrets/diffview.nvim" ít cập nhật từ 2024.
--  Nếu cần bản vá mới hơn, có thể đổi sang fork đang bảo trì:
--      "dlyongemallo/diffview.nvim"
--  (giữ nguyên config bên dưới, chỉ đổi dòng tên repo).
-- ============================================================

return {
    "sindrets/diffview.nvim",
    cmd = {
        "DiffviewOpen",
        "DiffviewClose",
        "DiffviewToggleFiles",
        "DiffviewFocusFiles",
        "DiffviewFileHistory",
    },

    -- ------------------------------------------------------------
    -- KEYMAPS (lazy-load theo phím). Namespace <leader>d* = "Diff ..."
    -- ------------------------------------------------------------
    keys = {
        -- Toggle: mở nếu chưa có view nào, đóng nếu đang mở
        {
            "<leader>dv",
            function()
                if next(require("diffview.lib").views) == nil then
                    vim.cmd("DiffviewOpen")
                else
                    vim.cmd("DiffviewClose")
                end
            end,
            desc = "Diffview: Toggle (working tree)",
        },
        { "<leader>dh", "<cmd>DiffviewFileHistory<CR>",   desc = "Diffview: Repo History",         silent = true },
        { "<leader>df", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: Current File History", silent = true },
        -- Lịch sử cho các dòng đang chọn (visual mode)
        { "<leader>df", ":DiffviewFileHistory<CR>",       desc = "Diffview: Selection History", mode = "v", silent = true },
        { "<leader>dx", "<cmd>DiffviewClose<CR>",         desc = "Diffview: Close",                silent = true },
    },

    config = function()
        local actions = require("diffview.actions")

        require("diffview").setup({
            enhanced_diff_hl = true,   -- tô màu diff rõ hơn (cả dòng thêm & xoá)
            view = {
                merge_tool = {
                    -- Bố cục 3 cửa sổ khi giải quyết conflict (ours | result | theirs)
                    layout            = "diff3_mixed",
                    disable_diagnostics = true,
                },
            },
            file_panel = {
                win_config = {
                    position = "left",
                    width    = 35,
                },
            },
            keymaps = {
                -- Giữ các default keymap (g? để xem toàn bộ trong view)
                disable_defaults = false,
                view = {
                    { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
                },
                file_panel = {
                    { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
                    -- <Tab>/<S-Tab>: chuyển file kế/trước (mặc định đã có, liệt kê cho rõ)
                    { "n", "<Tab>",   actions.select_next_entry, { desc = "Next file" } },
                    { "n", "<S-Tab>", actions.select_prev_entry, { desc = "Prev file" } },
                },
                file_history_panel = {
                    { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
                },
            },
        })
    end,
}
