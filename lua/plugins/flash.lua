-- ============================================================
--  plugins/flash.lua
-- ============================================================

return {
    "folke/flash.nvim",
    event = "VeryLazy",

    opts = {
        label = {
            uppercase = false,
        },

        modes = {
            -- `/`, `?`
            search = {
                enabled = true,
                highlight = {
                    backdrop = false,
                },
            },

            -- f/F/t/T
            char = {
                jump_labels = false,
                multi_line  = false,
            },
        },

        prompt = {
            enabled = false,
            prefix = { { "⚡", "FlashPromptIcon" } },
        },
    },

    -- ------------------------------------------------------------
    -- KEYMAPS
    -- ------------------------------------------------------------
    keys = {
        { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash jump" },
        { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash treesitter select" },
        { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Flash remote" },
        { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Flash treesitter search" },
        { "<C-s>", mode = "c",               function() require("flash").toggle() end,            desc = "Toggle Flash search" },
    },
}
