-- ============================================================
--  plugins/diffview.lua
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

    keys = {
        {
            "<leader>dv",
            function()
                local lib = require("diffview.lib")
                local view = lib.get_current_view()
                if view then
                    vim.cmd("DiffviewClose")
                else
                    vim.cmd("DiffviewOpen")
                end
            end,
            desc = "Diffview: Toggle (working tree)",
        },
        { "<leader>dh", "<cmd>DiffviewFileHistory<CR>",   desc = "Diffview: Repo History",         silent = true },
        { "<leader>df", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview: Current File History", silent = true },
        { "<leader>df", ":DiffviewFileHistory<CR>",       desc = "Diffview: Selection History",    mode = "v", silent = true },
        { "<leader>dx", "<cmd>DiffviewClose<CR>",         desc = "Diffview: Close",                silent = true },
    },

    config = function()
        local actions = require("diffview.actions")

        require("diffview").setup({
            use_icons = false,
            enhanced_diff_hl = true,
            show_help_hints = false,
            file_panel = {
                listing_style = "list",
                win_config = {
                    position = "right",
                    width    = 35,
                },
            },
            keymaps = {
                disable_defaults = false,

                view = {
                    { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
                    { "n", "<leader>go", actions.goto_file_tab, { desc = "Open file in new tab" } },
                },

                -- Cấu hình phím tắt tại thanh Sidebar danh sách file thay đổi
                file_panel = {
                    { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
                    { "n", "<Tab>",   actions.select_next_entry, { desc = "Next file" } },
                    { "n", "<S-Tab>", actions.select_prev_entry, { desc = "Prev file" } },
                    { "n", "<leader>go", actions.goto_file_tab, { desc = "Open file in new tab" } },
                    { "n", "X", actions.restore_entry, { desc = "Restore file changes" } },
                },
                file_history_panel = { { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } } },
            },
        })
    end,
}
