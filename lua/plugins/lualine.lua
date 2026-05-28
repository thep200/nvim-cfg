-- ============================================================
--  plugins/lualine.lua
-- ============================================================

return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "lewis6991/gitsigns.nvim" },
    config = function()
        local colors            = {
            none          = "#1d1d1d",
            dark          = "#0d1117",
            fg_med        = "#c9d1d9",

            normal        = "#22c55e",
            insert        = "#ff7b72",
            visual        = "#818cf8",
            replace       = "#3b82f6",
            command       = "#d2a8ff",

            diag_err      = "#ef4444",
            diag_warn     = "#fef08a",
            diag_info     = "#79c0ff",
            diag_hint     = "#fefce8",

            bg_by           = "#1e293b",
            bg_tag_inactive = "#1e293b",
            bg_tag_active   = "#334155",
        }

        local CX                = { fg = colors.fg_med, bg = colors.none }
        local BY                = { fg = colors.fg_med, bg = colors.bg_by }

        local normal_colors     = { fg = colors.dark, bg = colors.normal, bold = true }
        local insert_colors     = { fg = colors.dark, bg = colors.insert, bold = true }
        local visual_colors     = { fg = colors.dark, bg = colors.visual, bold = true }
        local replace_colors    = { fg = colors.dark, bg = colors.replace, bold = true }
        local command_colors    = { fg = colors.dark, bg = colors.command, bold = true }

        local tab_active        = { fg = colors.fg_med, bg = colors.bg_tag_active, bold = true }
        local tab_inactive      = { fg = colors.fg_med, bg = colors.bg_tag_inactive }

        local custom_theme      = {
            normal   = { a = normal_colors, b = BY, c = CX, x = CX, y = BY, z = normal_colors },
            insert   = { a = insert_colors, b = BY, c = CX, x = CX, y = BY, z = insert_colors },
            visual   = { a = visual_colors, b = BY, c = CX, x = CX, y = BY, z = visual_colors },
            replace  = { a = replace_colors, b = BY, c = CX, x = CX, y = BY, z = replace_colors },
            command  = { a = command_colors, b = BY, c = CX, x = CX, y = BY, z = command_colors },
            inactive = { a = normal_colors, b = BY, c = CX, x = CX, y = BY, z = normal_colors },
        }

        local diagnostics_color = {
            error = { fg = colors.diag_err },
            warn  = { fg = colors.diag_warn },
            info  = { fg = colors.diag_info },
            hint  = { fg = colors.diag_hint },
        }

        local events = {
            'WinEnter',
            'BufEnter',
            'Filetype',
            'VimResized',
            'ModeChanged',
            'CursorMoved',
            'CursorMovedI',
            'BufWritePost',
            'SessionLoadPost',
            'FileChangedShellPost',
        }

        local refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
            refresh_time = 16,
            events = events,
        }

        require('lualine').setup({
            options = {
                globalstatus         = true,
                icons_enabled        = true,
                always_divide_middle = true,
                always_show_tabline  = true,
                refresh              = refresh,
                theme                = custom_theme,
                component_separators = { left = '', right = '' },
                section_separators   = { left = '', right = '' },
            },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = {
                    {
                        'branch',
                        separator = '',
                        colors = {
                            fg = colors.none,
                            bg = colors.bg_by,
                        },
                        padding = { left = 1, right = 1 }
                    },
                },
                lualine_c = {
                    {
                        'diff',
                        symbols = {
                            added    = '+',
                            modified = '~',
                            removed  = '-',
                            -- added    = ' ',
                            -- modified = ' ',
                            -- removed  = ' ',
                        },
                    },
                },
                lualine_x = { 'filetype' },
                lualine_y = {
                    {
                        'diagnostics',
                        diagnostics_color = diagnostics_color,
                    }
                },
                lualine_z = {
                    {
                        'progress',
                        separator = '',
                        padding = { left = 1, right = 1 }
                    },
                    {
                        "%l/%L:%c",
                    },
                },
            },
            inactive_sections = {
                lualine_c = { 'filename' },
            },
            tabline = {
                lualine_a = {
                    {
                        'buffers',
                        mode = 0,
                        show_filename_only      = true,
                        hide_filename_extension = true,
                        buffers_color           = {active = tab_active, inactive = tab_inactive},
                    }
                },
            },
            extensions = { "neo-tree" }
        })
    end,
}
