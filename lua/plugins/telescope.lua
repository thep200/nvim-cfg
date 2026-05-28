-- ============================================================
--  plugins/telescope.lua
-- ============================================================

return {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    cmd    = "Telescope",

    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
        "nvim-telescope/telescope-ui-select.nvim",
    },

    -- ------------------------------------------------------------
    -- KEYMAPS
    -- ------------------------------------------------------------
    keys = {
        -- Namespace <leader>f* = "Find ..."
        { "<leader>ff", ":Telescope find_files<CR>", desc = "Find files",   silent = true },
        { "<leader>fb", ":Telescope buffers<CR>",    desc = "Find buffers", silent = true },
        { "<leader>fg", ":Telescope live_grep<CR>",  desc = "Find by Grep", silent = true },
        { "<leader>fl", ":Telescope current_buffer_fuzzy_find<CR>", desc = "Find lines in buffer", silent = true },
        { "<leader>fh", ":Telescope help_tags<CR>",             desc = "Find help",                silent = true },
        { "<leader>fk", ":Telescope keymaps<CR>",               desc = "Find keymaps",             silent = true },
        { "<leader>fo", ":Telescope oldfiles<CR>",              desc = "Find recent files",        silent = true },

        -- LSP pickers
        { "<leader>fd", ":Telescope diagnostics<CR>",           desc = "Find diagnostics",         silent = true },
        { "<leader>fr", ":Telescope lsp_references<CR>",        desc = "Find references",          silent = true },
        { "<leader>fs", ":Telescope lsp_document_symbols<CR>",  desc = "Find symbols (file)",      silent = true },
        { "<leader>fw", ":Telescope lsp_workspace_symbols<CR>", desc = "Find symbols (workspace)", silent = true },

        -- Git pickers
        { "<leader>gs", ":Telescope git_status<CR>",            desc = "Git status",               silent = true },
        { "<leader>gc", ":Telescope git_commits<CR>",           desc = "Git commits",              silent = true },
        { "<leader>gb", ":Telescope git_branches<CR>",          desc = "Git branches",             silent = true },
    },

    config = function()
        local telescope = require("telescope")
        local actions   = require("telescope.actions")
        local themes    = require("telescope.themes")

        telescope.setup({
            defaults = {
                layout_strategy = "horizontal",
                layout_config   = {
                    horizontal = {
                        width         = 0.6,
                        height        = 0.65,
                        preview_width = 0.55,
                    },
                },
                border          = true,
                borderchars     = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                prompt_prefix   = "  ",
                selection_caret = "  ",
                file_ignore_patterns = {
                    "%.git/",
                    "vendor/",
                    "node_modules/",
                    "__pycache__/",
                    "__debug_bin*",
                },

                mappings = {
                    i = {
                        ["<C-t>"]             = actions.select_tab,
                        ["<C-x>"]             = actions.select_horizontal,
                        ["<C-v>"]             = actions.select_vertical,
                        ["<Esc>"]             = actions.close,
                        ["<ScrollWheelUp>"]   = actions.move_selection_previous,
                        ["<ScrollWheelDown>"] = actions.move_selection_next,
                        ["<LeftMouse>"]       = false,
                        ["<RightMouse>"]      = false,
                    },
                    n = {
                        ["<ScrollWheelUp>"]   = actions.move_selection_previous,
                        ["<ScrollWheelDown>"] = actions.move_selection_next,
                        ["<LeftMouse>"]       = false,
                        ["<RightMouse>"]      = false,
                    },
                },
            },

            pickers = {
                find_files = {
                    hidden = true,
                    follow = true,
                    find_command = { "rg", "--files", "--hidden", "--follow" },
                },
                live_grep = {
                    additional_args = function()
                        return { "--hidden" }
                    end,
                },
            },

            extensions = {
                ["ui-select"] = {
                    themes.get_dropdown({
                        previewer     = false,
                        prompt_title  = "Select",
                        results_title = false,
                        layout_config = {
                            width  = 0.25,
                            height = 0.25,
                        },
                        borderchars = {
                            prompt  = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
                            results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
                            preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                        },
                    }),
                },
            },
        })

        pcall(telescope.load_extension, "fzf")
        pcall(telescope.load_extension, "ui-select")
    end,
}
