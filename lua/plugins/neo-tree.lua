-- ============================================================
--  plugins/neo-tree.lua
-- ============================================================

return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
        { "<leader>e", ":Neotree reveal toggle<CR>", desc = "Reveal Explorer", silent = true },
        { "<leader>o", ":Neotree toggle document_symbols position=right<CR>", desc = "Toggle Outline (Symbols)", silent = true },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        require("neo-tree").setup({
            sources = { "filesystem", "buffers", "git_status", "document_symbols" },
            close_if_last_window = true,
            enable_git_status    = true,
            enable_diagnostics   = true, -- E/W/I/? báo lỗi/cảnh báo cạnh tên file
            popup_border_style   = "rounded",
            hide_root_node = true,
            retain_hidden_root_indent = true,

            -- ============================================================
            -- 1. Cấu hình hiển thị (Giao diện ASCII tối giản)
            -- ============================================================
            default_component_configs = {
                indent = {
                    indent_size        = 2,
                    padding            = 1,
                    with_markers       = true,
                    indent_marker      = "┊", -- ╎, │
                    last_indent_marker = "╰",
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
                modified = {
                    symbol = "",
                    highlight = "NeoTreeModified"
                },
                name = {
                    use_git_status_colors = true,
                    highlight_opened_files = false,
                },
                diagnostics = {
                    symbols = {
                        error = ' ',
                        warn  = ' ',
                        info  = '󱧢 ',
                        hint  = '󰌶 ',
                    },
                    highlights = {
                        hint  = "DiagnosticSignHint",
                        info  = "DiagnosticSignInfo",
                        warn  = "DiagnosticSignWarn",
                        error = "DiagnosticSignError",
                    },
                },
                git_status = {
                    symbols = {
                        added     = "", -- File mới
                        modified  = "", -- Đã sửa
                        deleted   = "", -- Đã xóa
                        renamed   = "", -- Đổi tên
                        untracked = "", -- File mới
                        conflict  = "", -- Xung đột
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
                    ["<space>"] = "none",         -- Giải phóng phím Space
                    ["?"]       = "show_help",    -- Bảng trợ giúp
                    ["q"]       = "close_window", -- Đóng cửa sổ
                    ["<CR>"]    = "open",         -- Mở file
                    ["s"]       = "open_split",   -- Chia màn hình ngang
                    ["v"]       = "open_vsplit",  -- Chia màn hình dọc
                    ["t"]       = "open_tabnew",  -- Mở tab mới
                    ["H"]       = "toggle_hidden",-- Bật/tắt file ẩn
                    ["R"]       = "refresh",      -- Làm mới cây thư mục
                    ["O"]       = function() require("core.projects").open() end,
                },
            },

            -- ============================================================
            -- 3. Cấu hình Hệ thống File
            -- ============================================================
            filesystem = {
                use_libuv_file_watcher = true,
                follow_current_file = {
                    enabled              = true,
                    leave_dirs_open      = true,
                },
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

            -- ============================================================
            -- 4. Outline (Document Symbols) — yêu cầu LSP (gopls) đang attach
            -- ============================================================
            document_symbols = {
                follow_cursor = true,
                client_filters = "first",
                kinds = {
                    Function      = { icon = "󰊕", hl = "@function" },
                    Method        = { icon = "", hl = "@function.method" },
                    Struct        = { icon = "", hl = "@type" },
                    Interface     = { icon = "", hl = "@type" },
                    Class         = { icon = "", hl = "@type" },
                    Constructor   = { icon = "", hl = "@constructor" },
                    Enum          = { icon = "", hl = "@type" },
                    EnumMember    = { icon = "", hl = "@constant" },
                    Field         = { icon = "", hl = "@field" },
                    Property      = { icon = "", hl = "@property" },
                    Constant      = { icon = "", hl = "@constant" },
                    Variable      = { icon = "", hl = "@variable" },
                    Package       = { icon = "", hl = "@module" },
                    Module        = { icon = "󰏗", hl = "@module" },
                    Namespace     = { icon = "", hl = "@module" },
                    TypeParameter = { icon = "", hl = "@type" },
                    String        = { icon = "", hl = "@string" },
                    Number        = { icon = "", hl = "@number" },
                    Boolean       = { icon = "", hl = "@boolean" },
                    Array         = { icon = "", hl = "@punctuation.bracket" },
                    Object        = { icon = "", hl = "@punctuation.bracket" },
                },

                window = {
                    mappings = {
                        ["/"]    = "filter",
                        ["q"]    = "close_window",
                        ["<CR>"] = "jump_to_symbol",
                        ["o"]    = "jump_to_symbol",
                    },
                },
            },
        })
    end,
}
