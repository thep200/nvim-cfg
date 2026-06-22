-- ============================================================
--  plugins/neo-tree.lua
-- ============================================================

return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
        { "<leader>e", ":Neotree float reveal toggle<CR>", desc = "Float Explorer", silent = true },
        { "<leader>E", ":Neotree reveal toggle<CR>", desc = "Reveal Explorer", silent = true },
        { "<leader>o", ":Neotree toggle document_symbols position=right<CR>", desc = "Toggle Outline (Symbols)", silent = true },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        local material = require("core.material")
        local icons = material.icons
        local ascii = material.ascii

        require("neo-tree").setup({
            sources = { "filesystem", "buffers", "git_status", "document_symbols" },
            hide_root_node = true,
            close_if_last_window = true,
            enable_git_status    = true,
            enable_diagnostics   = true,
            popup_border_style   = "rounded",
            retain_hidden_root_indent = true,

            -- ============================================================
            -- 1. Cấu hình hiển thị (Giao diện ASCII tối giản)
            -- ============================================================
            default_component_configs = {
                indent = {
                    indent_size        = 2,
                    padding            = 1,
                    with_markers       = true,
                    indent_marker      = ascii.line_dash_extended,
                    last_indent_marker = ascii.line_last_corner,
                    highlight          = "NeoTreeIndentMarker",
                    with_expanders     = true,
                    expander_collapsed = ascii.collapse,
                    expander_expanded  = ascii.expand,
                    expander_highlight = "NeoTreeExpander",
                },
                icon = icons.tree_folder,
                modified = {
                    symbol = icons.tree_file_modified,
                    highlight = "NeoTreeModified"
                },
                name = {
                    use_git_status_colors = true,
                    highlight_opened_files = false,
                },
                diagnostics = {
                    symbols = icons.diagnostics,
                    highlights = {
                        hint  = "DiagnosticSignHint",
                        info  = "DiagnosticSignInfo",
                        warn  = "DiagnosticSignWarn",
                        error = "DiagnosticSignError",
                    },
                },
                git_status = {
                    symbols = icons.git,
                },
            },

            -- ============================================================
            -- 2. Cấu hình Cửa sổ & Phím tắt nội bộ
            -- ============================================================
            window = {
                position = "right",
                width    = 35,

                popup = {
                    position = "50%",
                    size = {
                        height = "80%",
                        width  = "50%",
                    },
                },

                mappings = {
                    ["<space>"] = "none",         -- Giải phóng phím Space
                    ["?"]       = "show_help",    -- Bảng trợ giúp
                    ["q"]       = "close_window", -- Đóng cửa sổ
                    ["<Esc>"]   = "close_window", -- Đóng cửa sổ bằng phím Esc
                    ["<CR>"]    = "open",         -- Mở file
                    ["s"]       = "open_split",   -- Chia màn hình ngang
                    ["v"]       = "open_vsplit",  -- Chia màn hình dọc
                    ["t"]       = "open_tabnew",  -- Mở tab mới
                    ["H"]       = "toggle_hidden",-- Bật/tắt file ẩn
                    ["R"]       = "refresh",      -- Làm mới cây thư mục

                    -- Các phím gập/mở thư mục (Folding)
                    ["h"]       = "close_node",       -- Gập folder hiện tại lại
                    ["l"]       = "open",             -- Mở folder hiện tại ra
                    ["W"]       = "close_all_nodes",  -- Gập toàn bộ cây thư mục (Viết hoa W)
                    ["E"]       = "expand_all_nodes", -- Mở bung toàn bộ cây thư mục (Viết hoa E)
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
                cwd_target = {
                    sidebar = "tab",
                    none = "index",
                },
                bind_to_cwd = true,

                filtered_items = {
                    visible         = true,
                    hide_dotfiles   = false,
                    hide_gitignored = false,
                    hide_by_name = {
                        ".idea",
                        ".vscode",
                        ".zed",
                        "claude",
                        "__pycache__",
                        "node_modules",
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
            -- 4. Outline (Document Symbols)
            -- ============================================================
            document_symbols = {
                follow_cursor = true,
                client_filters = "first",
                kinds = {
                    Function      = { icon = icons.doc.func, hl = "@function" },
                    Method        = { icon = icons.doc.method, hl = "@function.method" },
                    Struct        = { icon = icons.doc.struct, hl = "@type" },
                    Interface     = { icon = icons.doc.interface, hl = "@type" },
                    Class         = { icon = icons.doc.class, hl = "@type" },
                    Constructor   = { icon = icons.doc.constructor, hl = "@constructor" },
                    Enum          = { icon = icons.doc.enum, hl = "@type" },
                    EnumMember    = { icon = icons.doc.enumMember, hl = "@constant" },
                    Field         = { icon = icons.doc.field, hl = "@field" },
                    Property      = { icon = icons.doc.property, hl = "@property" },
                    Constant      = { icon = icons.doc.constant, hl = "@constant" },
                    Variable      = { icon = icons.doc.variable, hl = "@variable" },
                    Package       = { icon = icons.doc.package, hl = "@module" },
                    Module        = { icon = icons.doc.module, hl = "@module" },
                    Namespace     = { icon = icons.doc.namespace, hl = "@module" },
                    TypeParameter = { icon = icons.doc.typeParameter, hl = "@type" },
                    String        = { icon = icons.doc.string, hl = "@string" },
                    Number        = { icon = icons.doc.number, hl = "@number" },
                    Boolean       = { icon = icons.doc.boolean, hl = "@boolean" },
                    Array         = { icon = icons.doc.array, hl = "@punctuation.bracket" },
                    Object        = { icon = icons.doc.object, hl = "@punctuation.bracket" },
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
