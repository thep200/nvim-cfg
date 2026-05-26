-- ============================================================
--  plugins/neo-tree.lua
--  Thay thế: preservim/nerdtree + Xuyuanp/nerdtree-git-plugin
--
--  Lý do dùng neo-tree:
--    - Pure Lua, không cần external deps.
--    - Tự tích hợp git status (đỡ phải dùng nerdtree-git-plugin).
--    - Hỗ trợ buffer source / file source / git_status source.
--
--  Phím tắt giữ NGUYÊN: <C-b> toggle.
-- ============================================================

return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",                    -- lazy-load: chỉ load khi gọi :Neotree
    keys = {
        -- Ctrl+B để bật/tắt cây thư mục (giống VSCode + giống vim cũ)
        { "<C-b>", ":Neotree toggle<CR>", desc = "Toggle file explorer", silent = true },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",        -- thư viện util chung
        "MunifTanjim/nui.nvim",         -- UI primitives (popup, tree...)
        -- KHÔNG cần nvim-web-devicons (Nerd Font icons) - bạn đang dùng
        -- ASCII / arrow đơn giản theo style NERDTree cũ.
    },
    config = function()
        require("neo-tree").setup({
            -- ------------------------------------------------------------
            -- Vị trí & hiển thị (port từ nerdtree.vim)
            -- ------------------------------------------------------------
            close_if_last_window = true,    -- đóng Neovim nếu chỉ còn neo-tree
            popup_border_style   = "rounded",
            enable_git_status    = true,    -- thay nerdtree-git-plugin
            enable_diagnostics   = true,    -- hiển thị LSP diagnostics trong tree

            -- Không cần Nerd Font - tắt icon, dùng ký tự ASCII
            default_component_configs = {
                indent = {
                    indent_size       = 2,
                    padding           = 1,
                    with_markers      = true,
                    indent_marker     = "│",
                    last_indent_marker= "└",
                    highlight         = "NeoTreeIndentMarker",
                    -- expander = mũi tên đóng/mở folder (giống NERDTree cũ)
                    with_expanders         = true,
                    expander_collapsed     = "▶",
                    expander_expanded      = "▼",
                    expander_highlight     = "NeoTreeExpander",
                },
                icon = {
                    folder_closed = "",   -- không dùng nerd font icon
                    folder_open   = "",
                    folder_empty  = "",
                    default       = "",
                },
                modified = { symbol = "*", highlight = "NeoTreeModified" },
                name = {
                    use_git_status_colors = true,
                },
                -- Ký hiệu git status - dùng ASCII đơn giản (không Nerd Font,
                -- không Unicode dingbats) để render được trên mọi terminal/font.
                -- Style giống vim-gitgutter cũ: +/~/_
                git_status = {
                    symbols = {
                        added     = "+",  -- file mới được add
                        modified  = "~",  -- file đã sửa
                        deleted   = "_",  -- file đã xoá
                        renamed   = ">",  -- file đổi tên
                        untracked = "?",  -- file chưa track
                        ignored   = "",   -- không hiển thị icon cho file .gitignored
                                          -- (cho list neo-tree gọn, nhất là vendor/, node_modules/)
                        unstaged  = "",   -- gộp với modified
                        staged    = "",   -- gộp với added
                        conflict  = "!",  -- file conflict (merge)
                    },
                },
            },

            -- ------------------------------------------------------------
            -- Window config
            -- ------------------------------------------------------------
            window = {
                position = "right",      -- hiển thị bên phải (giống nerdtree cũ)
                width    = 35,
                mappings = {
                    -- Phím trong neo-tree: q để đóng, ? để xem help
                    ["<space>"] = "none", -- xoá map space mặc định để không nuốt leader
                    ["?"]       = "show_help",
                    ["q"]       = "close_window",
                    -- Mở file: Enter
                    ["<CR>"]    = "open",
                    -- Split mở file
                    ["s"]       = "open_split",
                    ["v"]       = "open_vsplit",
                    ["t"]       = "open_tabnew",
                    -- Toggle hidden
                    ["H"]       = "toggle_hidden",
                    -- Refresh
                    ["R"]       = "refresh",
                },
            },

            -- ------------------------------------------------------------
            -- Filesystem source - tương đương NERDTree config cũ
            -- ------------------------------------------------------------
            filesystem = {
                filtered_items = {
                    visible           = true,   -- hiển thị file ẩn mặc định
                                                -- (giống NERDTreeShowHidden = 1)
                    hide_dotfiles     = false,
                    hide_gitignored   = false,
                    -- Folder/file luôn ẩn (port từ NERDTreeIgnore)
                    hide_by_name = {
                        ".DS_Store",
                        "__pycache__",
                        "node_modules",
                        ".idea",
                        ".vscode",
                    },
                    hide_by_pattern = {
                        "*.pyc",
                        "__debug_bin*",   -- debug binary của delve
                    },
                    never_show = {
                        ".git",
                    },
                },
                follow_current_file = {
                    enabled = true,         -- auto reveal file đang edit trong tree
                },
                use_libuv_file_watcher = true,  -- detect thay đổi file ngay lập tức
                                                -- (thay vì poll - tiết kiệm CPU)
            },
        })
    end,
}
