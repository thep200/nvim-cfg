-- ============================================================
--  plugins/init.lua
--  Bootstrap lazy.nvim
-- ============================================================

-- ------------------------------------------------------------
-- 1. Tự động cài lazy.nvim nếu chưa có
-- ------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { import = "plugins.neo-tree" },          -- file explorer
    { import = "plugins.lualine" },           -- statusline
    { import = "plugins.gitsigns" },          -- git diff in sign column
    { import = "plugins.git-conflict" },      -- visualise & resolve merge conflicts
    { import = "plugins.diffview" },          -- single-tabpage diff & file history
    { import = "plugins.telescope" },         -- fuzzy finder
    { import = "plugins.treesitter" },        -- syntax highlight & more
    { import = "plugins.indent-blankline" },  -- indent guides (virtual text)
    { import = "plugins.cmp" },               -- completion engine (LSP + snippets + path + buffer)
    { import = "plugins.lsp" },               -- LSP client + gopls config (inlay hints, staticcheck, analyses,...)
    { import = "plugins.copilot" },           -- AI code completion (copilot.lua)
    { import = "plugins.codecompanion" },     -- AI chat + agent (copilot/claude/codex adapter)
    { import = "plugins.autopairs" },         -- auto-close (), [], {}, "", ''
    { import = "plugins.dap" },               -- debug adapter (Go via delve)
    { import = "plugins.neoscroll" },         -- smooth scrolling
}, {

    -- ------------------------------------------------------------
    -- Cấu hình chung cho lazy.nvim
    -- ------------------------------------------------------------
    install          = { colorscheme = { "habamax", "default" } }, -- built-in fallback khi install
    ui               = { border = "rounded" },
    change_detection = { notify = false },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
                "netrwPlugin",
            },
        },
    },
})
