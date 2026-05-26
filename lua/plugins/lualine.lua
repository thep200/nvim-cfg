-- ============================================================
--  plugins/lualine.lua
--  Thay thế: vim-airline + vim-airline-themes (+ tpope/vim-fugitive)
--
--  Port từ airline.vim: custom theme với màu riêng cho từng mode
--  giữ NGUYÊN bảng màu cũ:
--    Normal  : #4ade80 (xanh lá)
--    Insert  : #ff7b72 (đỏ)
--    Visual  : #818cf8 (tím indigo)
--    Replace : #3b82f6 (xanh dương)
--
--  Lualine tự đọc git branch từ vim.b.gitsigns_head (gitsigns set),
--  nên KHÔNG cần plugin fugitive nữa.
-- ============================================================

return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",     -- load sau khi UI vẽ xong -> startup nhanh hơn
    dependencies = {
        -- gitsigns sẽ set vim.b.gitsigns_head -> lualine đọc branch từ đây
        "lewis6991/gitsigns.nvim",
    },
    config = function()
        -- ------------------------------------------------------------
        -- Bảng màu (port y nguyên từ AirlineThemePatch trong airline.vim)
        -- ------------------------------------------------------------
        local colors = {
            dark      = "#0d1117",
            fg_med    = "#c9d1d9",
            branch_bg = "#94a3b8",

            normal    = "#4ade80",  -- Normal mode
            insert    = "#ff7b72",  -- Insert mode
            visual    = "#818cf8",  -- Visual mode
            replace   = "#3b82f6",  -- Replace mode
            command   = "#d2a8ff",  -- Command mode (bonus - airline cũ chưa có)

            warn_bg   = "#ffa657",
            warn_fg   = "#0d1117",
            err_bg    = "#b91c1c",
            err_fg    = "#f0f6fc",
        }

        -- ------------------------------------------------------------
        -- Theme tự define - struct lualine
        -- Mỗi mode có { a, b, c } - tương đương airline section a/b/c
        --   a = mode (gốc trái) - màu nổi bật
        --   b = branch / file info
        --   c = filename + content
        -- ------------------------------------------------------------
        local function mode_palette(mode_color)
            return {
                a = { bg = mode_color,    fg = colors.dark,      gui = "bold" },
                b = { bg = colors.branch_bg, fg = colors.dark },
                c = { bg = "NONE",        fg = colors.fg_med },
            }
        end

        local zed_theme = {
            normal   = mode_palette(colors.normal),
            insert   = mode_palette(colors.insert),
            visual   = mode_palette(colors.visual),
            replace  = mode_palette(colors.replace),
            command  = mode_palette(colors.command),
            inactive = {
                a = { bg = "NONE",        fg = colors.fg_med },
                b = { bg = "NONE",        fg = colors.fg_med },
                c = { bg = "NONE",        fg = colors.fg_med },
            },
        }

        -- ------------------------------------------------------------
        -- Setup lualine
        -- ------------------------------------------------------------
        require("lualine").setup({
            options = {
                theme               = zed_theme,
                icons_enabled       = false,        -- không dùng nerd font
                component_separators= { left = "", right = "" },
                section_separators  = { left = "", right = "" },
                globalstatus        = true,         -- 1 statusline duy nhất cho toàn nvim
                                                    -- (giống airline laststatus=2 cũ)
                disabled_filetypes  = {
                    statusline = { "neo-tree" },
                },
            },
            sections = {
                -- ---- Trái ----
                lualine_a = { "mode" },             -- mode (NORMAL/INSERT/...)
                lualine_b = {
                    {
                        "branch",                    -- thay vim-fugitive: lualine tự đọc git branch
                        icon = "",                  -- không dùng icon nerd font
                    },
                },
                lualine_c = {
                    {
                        "filename",
                        path        = 1,             -- 0=name, 1=relative, 2=absolute
                        symbols     = {
                            modified  = " ●",        -- file đã sửa
                            readonly  = " [RO]",
                            unnamed   = "[No Name]",
                        },
                    },
                },

                -- ---- Phải ----
                lualine_x = {
                    -- LSP diagnostics inline (bonus, vim-lsp cũ không có)
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        symbols = { error = "✗ ", warn = "! ", info = "i ", hint = "? " },
                    },
                    "filetype",
                },
                lualine_y = {},  -- để trống (giống airline_section_y = '')
                lualine_z = {
                    -- "p% l/L:c" - port từ airline_section_z cũ
                    function()
                        local line  = vim.fn.line(".")
                        local total = vim.fn.line("$")
                        local col   = vim.fn.col(".")
                        local pct   = math.floor(line / total * 100)
                        return string.format("%d%% %d/%d:%d", pct, line, total, col)
                    end,
                },
            },
        })
    end,
}
