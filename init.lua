-- ============================================================
--  Neovim configurations
--  Author: Thep200
-- ============================================================

require("core.options")
require("core.keymaps")
require("core.autocmds")

if vim.treesitter.language and not vim.treesitter.language.ft_to_lang then
    vim.treesitter.language.ft_to_lang = vim.treesitter.language.get_lang
        or function() return nil end
end

require("plugins")
require("core.colorscheme")
