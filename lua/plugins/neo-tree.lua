-- ============================================================
--  plugins/neo-tree.lua
--  Quản lý cây thư mục dự án (File Explorer)
-- ============================================================

return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
        { "<leader>e", ":Neotree reveal toggle<CR>", desc = "Reveal Explorer", silent = true },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        require("neo-tree").setup({
            close_if_last_window = true,
            enable_git_status    = true,
            enable_diagnostics   = true,
            popup_border_style   = "rounded",

            -- ============================================================
            -- 1. Cấu hình hiển thị (Giao diện ASCII tối giản)
            -- ============================================================
            default_component_configs = {
                indent = {
                    indent_size        = 2,
                    padding            = 1,
                    with_markers       = true,
                    indent_marker      = "│",
                    last_indent_marker = "└",
                    highlight          = "NeoTreeIndentMarker",
                    with_expanders     = true,
                    expander_collapsed = "▶",
                    expander_expanded  = "▼",
                    expander_highlight = "NeoTreeExpander",
                },
                icon = {
                    folder_closed = "",
                    folder_open   = "",
                    folder_empty  = "",
                    default       = "",
                },
                modified = { symbol = "*", highlight = "NeoTreeModified" },
                name     = { use_git_status_colors = true },

                -- Ký hiệu Git bằng ASCII đảm bảo hiển thị trên mọi Terminal
                git_status = {
                    symbols = {
                        added     = "+", -- File mới
                        modified  = "~", -- Đã sửa
                        deleted   = "_", -- Đã xóa
                        renamed   = ">", -- Đổi tên
                        untracked = "?", -- Chưa track
                        conflict  = "!", -- Xung đột
                        ignored   = "",  -- Ẩn icon cho file ignore cho gọn
                        unstaged  = "",
                        staged    = "",
                    },
                },
            },

            -- ============================================================
            -- 2. Cấu hình Cửa sổ & Phím tắt nội bộ
            -- ============================================================
            window = {
                position = "right",
                width    = 35,
                mappings = {
                    ["<space>"] = "none",          -- Giải phóng phím Space
                    ["?"]       = "show_help",     -- Bảng trợ giúp
                    ["q"]       = "close_window",  -- Đóng cửa sổ
                    ["<CR>"]    = "open",          -- Mở file
                    ["s"]       = "open_split",    -- Chia màn hình ngang
                    ["v"]       = "open_vsplit",   -- Chia màn hình dọc
                    ["t"]       = "open_tabnew",   -- Mở tab mới
                    ["H"]       = "toggle_hidden", -- Bật/tắt file ẩn
                    ["R"]       = "refresh",       -- Làm mới cây thư mục
                },
            },

            -- ============================================================
            -- 3. Cấu hình Hệ thống File (Bộ lọc)
            -- ============================================================
            filesystem = {
                use_libuv_file_watcher = true,
                follow_current_file = { enabled = true },
                filtered_items = {
                    visible         = true,
                    hide_dotfiles   = false,
                    hide_gitignored = false,
                    hide_by_name = {
                        "__pycache__",
                        "node_modules",
                        ".idea",
                        ".vscode",
                    },
                    hide_by_pattern = {},
                    never_show_by_pattern = {
                        "*.pyc",
                        ".DS_Store",
                        "__debug_bin*",
                    },
                    never_show = {
                        ".git",
                    },
                },
            },
        })
    end,
}
