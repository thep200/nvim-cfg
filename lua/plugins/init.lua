-- ============================================================
--  plugins/init.lua
--  Bootstrap lazy.nvim - plugin manager hiện đại của Neovim.
--
--  Lý do chọn lazy.nvim (thay vim-plug):
--    - Tự clone & quản lý plugin trong ~/.local/share/nvim/lazy/
--    - Lazy-load thông minh theo event/cmd/ft -> mở Neovim < 50ms
--    - UI quản lý plugin trực quan: :Lazy
--    - Lockfile để pin version giữa các máy
-- ============================================================

-- ------------------------------------------------------------
-- 1. Tự động cài lazy.nvim nếu chưa có
-- ------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ------------------------------------------------------------
-- 2. Khai báo danh sách plugin
--    Mỗi plugin = 1 file riêng trong lua/plugins/ để dễ maintain.
--    lazy.nvim sẽ tự require() tất cả file trong "plugins" folder.
-- ------------------------------------------------------------
require("lazy").setup({
    { import = "plugins.neo-tree" },
    { import = "plugins.lualine" },
    { import = "plugins.gitsigns" },
    { import = "plugins.telescope" },
    { import = "plugins.treesitter" },
    { import = "plugins.cmp" },
    { import = "plugins.lsp" },
}, {
    -- ------------------------------------------------------------
    -- Cấu hình chung cho lazy.nvim
    -- ------------------------------------------------------------
    install = {
        -- Tránh lazy load colorscheme khi cài lần đầu (mình tự load
        -- highlight ở core/colorscheme.lua nên cứ để default)
        colorscheme = { "default" },
    },
    ui = {
        border = "rounded",
    },
    change_detection = {
        notify = false,  -- không spam thông báo khi sửa config
    },
    performance = {
        rtp = {
            -- Tắt các plugin built-in không dùng -> startup nhanh hơn
            disabled_plugins = {
                "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
                "netrwPlugin",  -- thay bằng neo-tree
            },
        },
    },
})
