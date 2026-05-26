-- ============================================================
--  plugins/telescope.lua
--  Thay thế: junegunn/fzf + junegunn/fzf.vim
--
--  Lý do dùng telescope:
--    - Native Neovim, pure Lua (fzf cần binary external).
--    - Preview code có syntax highlight chuẩn (qua treesitter).
--    - Tích hợp sẵn các picker: lsp_references, diagnostics,
--      git_status, git_commits, ...
--
--  Keymap giữ NGUYÊN bằng cách map sang lệnh telescope tương ứng:
--    :Files    -> :Telescope find_files     (<C-p>, <D-S-p>)
--    :Buffers  -> :Telescope buffers        (<leader>b)
--    :Rg       -> :Telescope live_grep      (<leader>f)
--    :BLines   -> :Telescope current_buffer_fuzzy_find (<leader>l)
--
--  Yêu cầu CLI: ripgrep (cho live_grep) + fd (cho find_files nhanh hơn).
-- ============================================================

return {
    "nvim-telescope/telescope.nvim",
    -- branch "master" chứa fix cho lỗi ft_to_lang trên Neovim 0.11+.
    -- Branch "0.1.x" đã không còn được maintain (xem issue #3487).
    branch = "master",
    cmd  = "Telescope",
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
        -- ---- Port keymaps.vim ----
        -- <C-p> tìm file toàn project (giống Cmd+Shift+P VSCode)
        { "<C-p>",     ":Telescope find_files<CR>", desc = "Find files", silent = true },

        -- Bonus keymaps (port từ keymaps.vim cũ)
        { "<leader>b", ":Telescope buffers<CR>",                  desc = "List buffers", silent = true },
        { "<leader>f", ":Telescope live_grep<CR>",                desc = "Grep project", silent = true },
        { "<leader>l", ":Telescope current_buffer_fuzzy_find<CR>",desc = "Search current buffer lines", silent = true },

        -- ---- Bonus pickers cực hữu ích cho Go dev ----
        { "<leader>fd", ":Telescope diagnostics<CR>",  desc = "LSP diagnostics (tất cả buffer)", silent = true },
        { "<leader>fr", ":Telescope lsp_references<CR>", desc = "LSP references", silent = true },
        { "<leader>fs", ":Telescope lsp_document_symbols<CR>", desc = "Symbols trong file", silent = true },
        { "<leader>fw", ":Telescope lsp_workspace_symbols<CR>", desc = "Symbols toàn project", silent = true },
        { "<leader>gs", ":Telescope git_status<CR>",   desc = "Git status (file changed)", silent = true },
    },
    config = function()
        local telescope = require("telescope")
        local actions   = require("telescope.actions")

        telescope.setup({
            defaults = {
                -- Layout giống fzf cũ: popup nổi giữa
                layout_strategy = "horizontal",
                layout_config   = {
                    horizontal = {
                        width   = 0.85,
                        height  = 0.75,
                        preview_width = 0.55,
                    },
                },
                border          = true,
                borderchars     = {
                    "─", "│", "─", "│", "╭", "╮", "╯", "╰",
                },
                prompt_prefix   = "  ",
                selection_caret = " ",

                -- ---- Ignore patterns (port từ FZF_DEFAULT_COMMAND cũ) ----
                file_ignore_patterns = {
                    "%.git/",
                    "node_modules/",
                    "vendor/",
                    "%.pyc$",
                    "__pycache__/",
                    "__debug_bin",
                },

                -- ---- Mappings trong popup ----
                -- Giữ phím tắt fzf quen thuộc: ctrl-t = tab, ctrl-x = split, ctrl-v = vsplit
                mappings = {
                    i = {
                        ["<C-t>"] = actions.select_tab,
                        ["<C-x>"] = actions.select_horizontal,
                        ["<C-v>"] = actions.select_vertical,
                        ["<Esc>"] = actions.close,    -- Esc đóng luôn (không vào normal mode)
                    },
                },
            },
            pickers = {
                find_files = {
                    hidden = true,    -- hiển thị dotfiles (port --hidden cũ)
                    follow = true,    -- follow symlink
                },
                live_grep = {
                    additional_args = function() return { "--hidden" } end,
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
