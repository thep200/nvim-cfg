-- ============================================================
--  plugins/treesitter.lua
--  Plugin MỚI (vim cũ không có). Vì sao cần?
--
--  - Vim cũ dùng regex để highlight syntax (file ftplugin / syntax/).
--    Với Go: 'goFunctionCall' phải tự match bằng regex như trong
--    appearance.vim cũ.
--  - Treesitter dùng AST -> highlight CHÍNH XÁC (không nhầm comment
--    trong string, không sai function vs method,...).
--  - Lua theme ở core/colorscheme.lua đã map @function, @type, @field
--    -> cần treesitter để các capture group đó tồn tại.
--
--  Lightweight: chỉ install parser cho ngôn ngữ dùng thật.
-- ============================================================

return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",                    -- compile parser sau khi cài
    event = { "BufReadPre", "BufNewFile" }, -- lazy-load khi mở file
    config = function()
        require("nvim-treesitter.configs").setup({
            -- ------------------------------------------------------------
            -- Parser cần install. Định hướng Go dev -> tập trung Go family.
            -- Có thể thêm: "rust", "python", "javascript",... khi cần.
            -- ------------------------------------------------------------
            ensure_installed = {
                "go", "gomod", "gosum", "gowork",  -- Go ecosystem
                "lua", "vim", "vimdoc",            -- Để config Neovim tốt hơn
                "bash", "json", "yaml", "toml",    -- Config files thường gặp
                "markdown", "markdown_inline",
                "dockerfile", "make",
                "sql",
            },
            sync_install = false,
            auto_install = true,        -- tự install parser khi mở filetype mới

            highlight = {
                enable = true,
                -- KHÔNG dùng regex syntax đồng thời (gây màu xung đột với theme)
                additional_vim_regex_highlighting = false,
            },

            indent = {
                enable = true,          -- indent thông minh dựa trên AST
            },

            -- Bonus: incremental selection - select theo AST node
            -- (vd: chọn cả block if, cả function body... rất tiện refactor)
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
