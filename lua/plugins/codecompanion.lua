-- ============================================================
-- plugins/codecompanion.lua
-- ============================================================
local CHAT_ADAPTER = "copilot"

return {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
        "CodeCompanion",
        "CodeCompanionChat",
        "CodeCompanionCmd",
        "CodeCompanionActions",
    },
    keys = {
        { "<leader>aa", "<cmd>CodeCompanionActions<cr>",     mode = { "n", "v" }, desc = "AI: Actions" },
        { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI: Toggle Chat" },
        { "<leader>ai", ":CodeCompanion ",                   mode = { "n", "v" }, desc = "AI: Inline Prompt" },
        { "ga",         "<cmd>CodeCompanionChat Add<cr>",    mode = "v",          desc = "AI: Add Selection" },
    },
    config = function()
        -- [BỔ SUNG QUAN TRỌNG]: Ép Neovim luôn mở các cửa sổ dọc (vsplit) sang bên phải
        vim.opt.splitright = true

        require("codecompanion").setup({

            -- ============================================================
            -- BỔ SUNG CẤU HÌNH HIỂN THỊ (DISPLAY)
            -- ============================================================
            display = {
                chat = {
                    window = {
                        layout = "vertical", -- Ép pane chat mở theo chiều dọc
                        width = 40,          -- Chiều rộng của pane chat (bạn có thể tăng giảm số này)
                    },
                },
            },

            interactions = {
                chat   = { adapter = CHAT_ADAPTER },
                inline = { adapter = "copilot" },
            },
            adapters = {
                acp = {
                    -- Claude Code + zed-industries/claude-agent-acp
                    -- claude_code = function()
                    --     return require("codecompanion.adapters").extend("claude_code", {
                    --         env = { CLAUDE_CODE_OAUTH_TOKEN = "cmd:cat ~/.claude/oauth_token" },
                    --     })
                    -- end,
                },
            },
        })

        -- :cc -> :CodeCompanion
        vim.cmd([[cab cc CodeCompanion]])
    end,
}
