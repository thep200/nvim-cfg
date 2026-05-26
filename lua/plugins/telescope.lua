-- ============================================================
--  plugins/telescope.lua
--  Fuzzy finder cho Neovim (thay junegunn/fzf + fzf.vim).
--
--  Namespace keymap: <leader>f* là PREFIX cho mọi picker "Find ...".
--  Grep project được tách sang <leader>/ để tránh conflict prefix
--  (xem comment chi tiết ở block keys bên dưới).
--
--  Yêu cầu CLI: ripgrep (cho live_grep) + fd (cho find_files nhanh hơn).
-- ============================================================

return {
    "nvim-telescope/telescope.nvim",
    -- branch "master" chứa fix cho lỗi ft_to_lang trên Neovim 0.11+.
    -- Branch "0.1.x" đã không còn được maintain (xem issue #3487).
    branch = "master",

    -- Pre-warm telescope sau khi UI vẽ xong (~50ms sau startup).
    -- Khi user bấm phím tắt, telescope đã sẵn trong memory -> mở tức thì.
    event = "VeryLazy",

    dependencies = {
        "nvim-lua/plenary.nvim",

        -- fzf-native là extension C giúp telescope sort/match cực nhanh.
        -- Cần `make` lúc build - nếu máy không có gcc/clang thì sửa
        -- `build = "make"` thành `enabled = false` để bỏ.
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },

    keys = {
        -- ------------------------------------------------------------
        -- Phím tắt nhanh (không prefix với <leader>f để tránh conflict)
        -- ------------------------------------------------------------
        -- <C-p> tìm file toàn project (giống Cmd+Shift+P VSCode)
        { "<C-p>",     ":Telescope find_files<CR>", desc = "Find files (quick)", silent = true },

        -- <leader>/ grep project (snappy, không bị timeoutlen chờ prefix)
        { "<leader>/", ":Telescope live_grep<CR>",  desc = "Grep project",       silent = true },

        -- <leader>l tìm trong buffer hiện tại (port :BLines của fzf)
        {
            "<leader>l",
            ":Telescope current_buffer_fuzzy_find<CR>",
            desc = "Search current buffer",
            silent = true
        },

        -- ------------------------------------------------------------
        -- Namespace <leader>f* = "Find ..."
        -- which-key sẽ group thành menu "Find / Telescope" (đã có sẵn ở
        -- spec which-key của bạn).
        --
        -- Đặt grep ở <leader>fg (Find by Grep) cho ai quen prefix f.
        -- ------------------------------------------------------------
        { "<leader>ff", ":Telescope find_files<CR>", desc = "Find files",   silent = true },
        { "<leader>fb", ":Telescope buffers<CR>",    desc = "Find buffers", silent = true },
        { "<leader>fg", ":Telescope live_grep<CR>",  desc = "Find by Grep", silent = true },
        {
            "<leader>fl",
            ":Telescope current_buffer_fuzzy_find<CR>",
            desc = "Find lines in buffer",
            silent = true
        },
        { "<leader>fh", ":Telescope help_tags<CR>",             desc = "Find help",                silent = true },
        { "<leader>fk", ":Telescope keymaps<CR>",               desc = "Find keymaps",             silent = true },
        { "<leader>fo", ":Telescope oldfiles<CR>",              desc = "Find recent files",        silent = true },

        -- ------------------------------------------------------------
        -- LSP pickers (vẫn nằm trong namespace Find)
        -- ------------------------------------------------------------
        { "<leader>fd", ":Telescope diagnostics<CR>",           desc = "Find diagnostics",         silent = true },
        { "<leader>fr", ":Telescope lsp_references<CR>",        desc = "Find references",          silent = true },
        { "<leader>fs", ":Telescope lsp_document_symbols<CR>",  desc = "Find symbols (file)",      silent = true },
        { "<leader>fw", ":Telescope lsp_workspace_symbols<CR>", desc = "Find symbols (workspace)", silent = true },

        -- ------------------------------------------------------------
        -- Git pickers
        -- ------------------------------------------------------------
        { "<leader>gs", ":Telescope git_status<CR>",            desc = "Git status",               silent = true },
        { "<leader>gc", ":Telescope git_commits<CR>",           desc = "Git commits",              silent = true },
        { "<leader>gb", ":Telescope git_branches<CR>",          desc = "Git branches",             silent = true },
    },

    config = function()
        local telescope = require("telescope")
        local actions   = require("telescope.actions")

        telescope.setup({
            defaults = {
                -- ---- Layout giống fzf cũ: popup nổi giữa, có preview ----
                layout_strategy = "horizontal",
                layout_config   = {
                    horizontal = {
                        width         = 0.85,
                        height        = 0.75,
                        preview_width = 0.55,
                    },
                },
                border          = true,
                borderchars     = {
                    "─", "│", "─", "│", "╭", "╮", "╯", "╰",
                },
                prompt_prefix   = "  ",
                selection_caret = " ",

                -- ---- Mappings trong popup ----
                -- Giữ phím tắt fzf quen thuộc:
                --   <C-t> = open in tab
                --   <C-x> = open in horizontal split
                --   <C-v> = open in vertical split
                --   <Esc> = đóng luôn (không vào normal mode trong picker)
                mappings        = {
                    i = {
                        ["<C-t>"] = actions.select_tab,
                        ["<C-x>"] = actions.select_horizontal,
                        ["<C-v>"] = actions.select_vertical,
                        ["<Esc>"] = actions.close,
                    },
                },
            },

            pickers = {
                -- ------------------------------------------------------------
                -- find_files: dùng rg với glob để skip vendor/, node_modules/
                -- ngay từ NGUỒN (nhanh hơn rất nhiều so với file_ignore_patterns
                -- vốn chỉ filter sau khi rg đã quét xong).
                -- ------------------------------------------------------------
                find_files = {
                    hidden = true,
                    follow = true,
                    find_command = {
                        "rg",
                        "--files",
                        "--hidden",
                        "--follow",
                        "--glob",
                        "!**/.git/*",
                        "--glob", "!**/vendor/*",
                        "--glob", "!**/node_modules/*",
                        "--glob", "!**/__pycache__/*",
                        "--glob", "!**/__debug_bin*",
                    },
                },

                -- ------------------------------------------------------------
                -- live_grep: cùng nguyên tắc - đẩy ignore xuống rg
                -- ------------------------------------------------------------
                live_grep = {
                    additional_args = function()
                        return {
                            "--hidden",
                            "--glob",
                            "!**/.git/*",
                            "--glob",
                            "!**/vendor/*",
                            "--glob", "!**/node_modules/*",
                            "--glob", "!**/__pycache__/*",
                            "--glob", "!**/__debug_bin*",
                        }
                    end,
                },

                lsp_references = {
                    file_ignore_patterns = { "vendor/", "node_modules/" },
                    include_declaration = true,   -- include cả nơi khai báo
                    include_current_line = false, -- không include dòng cursor đang đứng
                    show_line = false,            -- ẩn nội dung dòng, chỉ hiện đường dẫn
                },
                lsp_definitions = {
                    file_ignore_patterns = { "vendor/", "node_modules/" },
                    show_line = false,
                },
                lsp_implementations = {
                    file_ignore_patterns = { "vendor/", "node_modules/" },
                    show_line = false,
                },
            },
        })

        -- ------------------------------------------------------------
        -- Load extension fzf-native (nếu build thành công)
        -- pcall để khi máy không có make/gcc cũng không lỗi
        -- ------------------------------------------------------------
        pcall(telescope.load_extension, "fzf")
    end,
}
