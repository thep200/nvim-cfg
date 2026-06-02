-- ============================================================
--  plugins/lualine.lua
-- ============================================================

return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "lewis6991/gitsigns.nvim" },
    config = function()
        local material = require("core.material")
        local icons = material.icons
        local colors = material.colors.lualine
        -- local colors = require("core.material").colors.lualine
        -- local colors            = {
        --     none          = "#1d1d1d",
        --     dark          = "#0d1117",
        --     fg_med        = "#c9d1d9",

        --     normal        = "#22c55e",
        --     insert        = "#ff7b72",
        --     visual        = "#818cf8",
        --     replace       = "#3b82f6",
        --     command       = "#d2a8ff",

        --     diag_err      = "#ef4444",
        --     diag_warn     = "#fef08a",
        --     diag_info     = "#79c0ff",
        --     diag_hint     = "#fefce8",

        --     bg_by           = "#1e293b",
        --     bg_tag_inactive = "#1e293b",
        --     bg_tag_active   = "#334155",
        -- }

        local CX                = { fg = colors.fg_med, bg = colors.none }
        local BY                = { fg = colors.fg_med, bg = colors.bg_by }

        local normal_colors     = { fg = colors.dark, bg = colors.normal, bold = true }
        local insert_colors     = { fg = colors.dark, bg = colors.insert, bold = true }
        local visual_colors     = { fg = colors.dark, bg = colors.visual, bold = true }
        local replace_colors    = { fg = colors.dark, bg = colors.replace, bold = true }
        local command_colors    = { fg = colors.dark, bg = colors.command, bold = true }

        local custom_theme      = {
            normal   = { a = normal_colors, b = BY, c = CX, x = CX, y = BY, z = normal_colors },
            insert   = { a = insert_colors, b = BY, c = CX, x = CX, y = BY, z = insert_colors },
            visual   = { a = visual_colors, b = BY, c = CX, x = CX, y = BY, z = visual_colors },
            replace  = { a = replace_colors, b = BY, c = CX, x = CX, y = BY, z = replace_colors },
            command  = { a = command_colors, b = BY, c = CX, x = CX, y = BY, z = command_colors },
            inactive = { a = normal_colors, b = BY, c = CX, x = CX, y = BY, z = normal_colors },
        }

        local events = {
            'WinEnter',
            'BufEnter',
            'Filetype',
            'VimResized',
            'ModeChanged',
            'CursorMoved',
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
                always_show_tabline  = false,
                refresh              = refresh,
                theme                = custom_theme,
                section_separators   = icons.lualine_sep.slant_up.section,
                component_separators = icons.lualine_sep.slant_up.component,
            },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = {
                    {
                        'branch',
                        separator = '',
                        padding = { left = 1, right = 1 }
                    },
                },
                lualine_c = {
                    {
                        'filename',
                        path = 1,
                        shorting_target = 40,
                        separator = '',
                        padding = { left = 1, right = 0 }
                    },
                    {
                        'diff',
                        symbols = icons.git_diff,
                    },
                },
                lualine_x = { 'filetype' },
                lualine_y = {
                    {
                        'diagnostics',
                        diagnostics_color = {
                            error = { fg = colors.diag_err },
                            warn  = { fg = colors.diag_warn },
                            info  = { fg = colors.diag_info },
                            hint  = { fg = colors.diag_hint },
                        },
                        symbols = icons.diagnostics,
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
                lualine_c = {
                    'filename',
                },
            },
            extensions = { "neo-tree" }
        })
    end,
}
