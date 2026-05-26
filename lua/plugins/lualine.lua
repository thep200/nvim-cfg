-- ============================================================
--  plugins/lualine.lua
--  Thay thế: vim-airline + vim-airline-themes (+ tpope/vim-fugitive)
--
--  Port từ airline.vim: custom theme với màu riêng cho từng mode:
--    Normal  : #4ade80 (xanh lá)
--    Insert  : #ff7b72 (đỏ)
--    Visual  : #818cf8 (tím indigo)
--    Replace : #3b82f6 (xanh dương)
--
--  Layout:
--     │ NORMAL │  main +3 ~1 -2 │ path/to/file.go      45% 87:23  go │ E:2 W:1 │
--      ── a ──  ────── b ──────  ─────── c ────────  ────── x ──────── ─ z ──
--
--  ⚠️ YÊU CẦU NERD FONT cài trên terminal (vd: JetBrainsMono Nerd Font,
--    Fira Code Nerd Font, ...). Cài tại: https://www.nerdfonts.com
--    Không có Nerd Font, các glyph "" "" "" sẽ thành ô vuông ▢.
-- ============================================================

return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
        "lewis6991/gitsigns.nvim",  -- để lualine đọc branch + diff
    },
    config = function()
        -- ------------------------------------------------------------
        -- Bảng màu (port y nguyên từ AirlineThemePatch trong airline.vim)
        -- ------------------------------------------------------------
        local colors = {
            dark      = "#0d1117",
            fg_med    = "#c9d1d9",
            branch_bg = "#94a3b8",

            normal    = "#4ade80",
            insert    = "#ff7b72",
            visual    = "#818cf8",
            replace   = "#3b82f6",
            command   = "#d2a8ff",

            -- Diagnostic colors (cho section z) - lấy từ zed_github_dark
            diag_err  = "#b91c1c",
            diag_warn = "#ffa657",
            diag_info = "#79c0ff",
            diag_hint = "#9198a1",
        }

        -- Mỗi mode share 1 cấu trúc palette. a / z dùng màu mode (đầu/cuối),
        -- b dùng màu xám nhạt (branch_bg), c trong suốt.
        local function mode_palette(mode_color)
            return {
                a = { bg = mode_color,       fg = colors.dark,    gui = "bold" },
                b = { bg = colors.branch_bg, fg = colors.dark },
                c = { bg = "NONE",           fg = colors.fg_med },
                -- x, y, z lualine tự mirror từ c, b, a nếu không khai báo
            }
        end

        local zed_theme = {
            normal   = mode_palette(colors.normal),
            insert   = mode_palette(colors.insert),
            visual   = mode_palette(colors.visual),
            replace  = mode_palette(colors.replace),
            command  = mode_palette(colors.command),
            inactive = {
                a = { bg = "NONE", fg = colors.fg_med },
                b = { bg = "NONE", fg = colors.fg_med },
                c = { bg = "NONE", fg = colors.fg_med },
            },
        }

        -- ------------------------------------------------------------
        -- Custom component cho lualine_x: vị trí "p% l:c"
        --
        -- LƯU Ý ESCAPE %: lualine không tự escape '%' (token statusline),
        -- phải return "%%" để render thành 1 dấu '%' literal.
        -- Trong string.format -> "%%%%" (4 dấu).
        -- ------------------------------------------------------------
        local function position()
            local line  = vim.fn.line(".")
            local total = vim.fn.line("$")
            local col   = vim.fn.col(".")
            if total == 0 then return "" end
            local pct = math.floor(line / total * 100)
            return string.format("%d%%%% %d:%d", pct, line, col)
        end

        require("lualine").setup({
            options = {
                theme         = zed_theme,
                icons_enabled = true,    -- BẬT icons để có icon nhánh git

                -- ---- Powerline separators (mũi nhọn) ----
                -- '' (U+E0B0) và '' (U+E0B2) cần Nerd Font.
                -- Nếu font không hỗ trợ, có thể thay '▶' '◀' (Unicode block arrows).
                section_separators   = { left = "", right = "" },
                component_separators = { left = "", right = "" },

                globalstatus       = true,
                disabled_filetypes = {},
            },

            sections = {
                -- ============================================================
                -- TRÁI
                -- ============================================================

                -- ---- a: Mode (NORMAL / INSERT / ...) ----
                lualine_a = { "mode" },

                -- ---- b: Branch + git diff ----
                lualine_b = {
                    {
                        "branch",
                        icon = "",      -- Powerline branch glyph (U+E0A0)
                                          -- Đổi sang "git:" nếu không có Nerd Font
                    },
                    {
                        "diff",
                        -- Đọc git diff từ gitsigns (đã set vim.b.gitsigns_status_dict).
                        -- 3 ký tự ASCII đơn giản - không cần Nerd Font.
                        symbols = {
                            added    = "+",
                            modified = "~",
                            removed  = "-",
                        },
                        -- Tô màu theo theme (xanh/cam/đỏ)
                        diff_color = {
                            added    = { fg = colors.normal },
                            modified = { fg = colors.insert },
                            removed  = { fg = colors.replace },
                        },
                    },
                },

                -- ---- c: Tên file ----
                lualine_c = {
                    {
                        "filename",
                        path = 1,        -- 0=name, 1=relative, 2=absolute
                        symbols = {
                            modified = " [+]",
                            readonly = " [RO]",
                            unnamed  = "[No Name]",
                        },
                    },
                },

                -- ============================================================
                -- PHẢI
                -- ============================================================

                -- ---- x: Vị trí cursor + filetype ----
                lualine_x = {
                    position,                          -- p% l:c
                    "filetype",
                },

                -- ---- y: bỏ trống (để layout gọn) ----
                lualine_y = {},

                -- ---- z: Diagnostic (LSP error/warn) - NGOÀI CÙNG PHẢI ----
                lualine_z = {
                    {
                        "diagnostics",
                        sources         = { "nvim_diagnostic" },
                        sections        = { "error", "warn", "info", "hint" },
                        symbols         = {
                            error = "E:",
                            warn  = "W:",
                            info  = "I:",
                            hint  = "H:",
                        },
                        -- Override màu để text dễ đọc trên bg = mode color.
                        -- Override = fg luôn theo severity, không bị nuốt
                        -- bởi màu mode của section z.
                        diagnostics_color = {
                            error = { fg = colors.diag_err  },
                            warn  = { fg = colors.diag_warn },
                            info  = { fg = colors.diag_info },
                            hint  = { fg = colors.diag_hint },
                        },
                        colored          = true,
                        update_in_insert = false,
                        always_visible   = false,    -- ẩn khi không có diagnostic
                    },
                },
            },
        })
    end,
}
