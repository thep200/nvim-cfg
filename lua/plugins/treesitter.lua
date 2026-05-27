-- ============================================================
--  plugins/treesitter.lua
-- ============================================================

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "go", "gomod", "gosum", "gowork",
                "lua", "vim", "vimdoc",
                "bash", "json", "yaml", "toml",
                "markdown", "markdown_inline",
                "dockerfile", "make",
                "sql",
            },
            sync_install = false,
            auto_install = true,

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },

            indent = {
                enable = true,
            },

            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection    = "<C-space>",
                    node_incremental  = "<C-space>",
                    scope_incremental = false,
                    node_decremental  = "<bs>",
                },
            },
        })
    end,
}
