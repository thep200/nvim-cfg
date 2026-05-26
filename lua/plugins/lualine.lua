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
        }

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
        -- Custom z component: "p% l/L:c" - port từ airline_section_z cũ.
        --
        -- LƯU Ý ESCAPE %:
        --   Lualine KHÔNG tự escape ký tự "%" trong chuỗi return từ custom
        --   function. Mà "%" lại là token format của Vim statusline (vd %f,
        --   %l). Nếu trả về "56% 1/100:1" thẳng thì Vim sẽ tưởng "% " là
        --   format spec lỗi → có thể gây "E539: Illegal character < >" hoặc
        --   các lỗi parse statusline khác.
        --
        --   Cách đúng: trả về "56%% 1/100:1" - hai dấu % để Vim render thành
        --   một ký tự % literal. Trong string.format ta cần "%%%%" (4 dấu)
        --   vì string.format ăn 2 dấu để tạo 1 dấu, rồi statusline parser
        --   ăn 2 dấu nữa để render 1 dấu thực sự.
        -- ------------------------------------------------------------
        local function position()
            local line  = vim.fn.line(".")
            local total = vim.fn.line("$")
            local col   = vim.fn.col(".")
            if total == 0 then return "" end
            local pct = math.floor(line / total * 100)
            return string.format("%d%%%% %d/%d:%d", pct, line, total, col)
        end

        require("lualine").setup({
            options = {
                theme               = zed_theme,
                icons_enabled       = false,        -- không dùng nerd font
                component_separators= "",           -- không có separator giữa component
                section_separators  = "",           -- không có separator giữa section
                globalstatus        = true,         -- 1 statusline global cho toàn nvim
                disabled_filetypes  = {},           -- không disable cho ai - statusline luôn hiện
            },
            sections = {
                -- ---- Trái ----
                lualine_a = { "mode" },             -- mode (NORMAL/INSERT/...)
                lualine_b = { "branch" },           -- git branch (đọc từ gitsigns)
                lualine_c = {
                    {
                        "filename",
                        path        = 1,            -- 0=name, 1=relative, 2=absolute
                        symbols     = {
                            modified  = " [+]",
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
                        symbols = { error = "E ", warn = "W ", info = "I ", hint = "H " },
                    },
                    "filetype",
                },
                lualine_y = {},                     -- để trống (giống airline_section_y = '')
                lualine_z = { position },           -- "p% l/L:c"
            },
        })
    end,
}
