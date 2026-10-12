-- ============================================================
--  plugins/auto-session.lua
-- ============================================================
return {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
        suppressed_dirs = { "~/", "~/Downloads", "~/Documents", "/" },
        session_lens = {
            -- Không nạp telescope lúc khởi động (~20ms); picker vẫn tự
            -- nạp khi gọi :AutoSession search
            load_on_setup = false,
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
