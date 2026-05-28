-- ============================================================
--  Neovim configurations
--  Author: Thep200
-- ============================================================

require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Compat: ft_to_lang bị bỏ ở Neovim 0.11, redirect sang get_lang
if vim.treesitter.language and not vim.treesitter.language.ft_to_lang then
    vim.treesitter.language.ft_to_lang = vim.treesitter.language.get_lang
end

require("plugins")
require("core.colorscheme")
