-- ============================================================
--  plugins/auto-session.lua
-- ============================================================
return {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
        suppressed_dirs = { "~/", "~/Downloads", "~/Documents", "/" },
        session_lens = {
            previewer = false,
            mappings = {
                delete_session = { "i", "<C-d>" },
            },
        },
    },
    keys = {
        { "<leader>qs", "<cmd>AutoSession search<CR>",  desc = "Search sessions" },
    },
}
