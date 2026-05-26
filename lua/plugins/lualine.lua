-- ============================================================
--  plugins/lualine.lua
-- ============================================================

return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {"lewis6991/gitsigns.nvim"},
    config = function()
        -- Config for sections themes
        local colors = {
            none      = "#1d1d1d",
            dark      = "#0d1117",
            fg_med    = "#c9d1d9",

            normal    = "#16a34a",
            insert    = "#ff7b72",
            visual    = "#818cf8",
            replace   = "#3b82f6",
            command   = "#d2a8ff",

            diag_err  = "#ef4444",
            diag_warn = "#fef08a",
            diag_info = "#79c0ff",
            diag_hint = "#fefce8",

            background_by = "#0f172a",
        }

        local CX = { fg = colors.fg_med, bg = colors.none       }
        local BY = { fg = colors.fg_med,   bg = colors.background_by  }

        local normal_colors  = { fg = colors.dark, bg = colors.normal,  bold = true }
        local insert_colors  = { fg = colors.dark, bg = colors.insert,  bold = true }
        local visual_colors  = { fg = colors.dark, bg = colors.visual,  bold = true }
        local replace_colors = { fg = colors.dark, bg = colors.replace, bold = true }
        local command_colors = { fg = colors.dark, bg = colors.command, bold = true }

        local custom_theme = {
            normal   = { a = normal_colors,  b = BY, c = CX, x = CX, y = BY, z = normal_colors  },
            insert   = { a = insert_colors,  b = BY, c = CX, x = CX, y = BY, z = insert_colors  },
            visual   = { a = visual_colors,  b = BY, c = CX, x = CX, y = BY, z = visual_colors  },
            replace  = { a = replace_colors, b = BY, c = CX, x = CX, y = BY, z = replace_colors },
            command  = { a = command_colors, b = BY, c = CX, x = CX, y = BY, z = command_colors },
            inactive = { a = normal_colors,  b = BY, c = CX, x = CX, y = BY, z = normal_colors  },
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

        require('lualine').setup ({
            options = {
                globalstatus         = true,
                icons_enabled        = true,
                always_divide_middle = true,
                always_show_tabline  = false,
                refresh              = refresh,
                theme                = custom_theme,
                component_separators = { left = '', right = ''},
                section_separators   = { left = '', right = ''},
            },
            sections = {
                lualine_a = {'mode'},
                lualine_b = {
                    'branch',
                    'diff',
                },
                lualine_c = {'filename'},
                lualine_x = {'filetype'},
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
                        padding = { left = 1, right = 0 }
                    },
                    {
                        'location',
                        padding = { left = 1, right = 1 }
                    }
                },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {'location'},
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = {"neo-tree"}
        })
    end,
}
