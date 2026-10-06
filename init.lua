-- ============================================================
--  Neovim configurations
--  Author: Thep200
-- ============================================================

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("commands")
require("animation.hooks").setup()

-- Patch tương thích trước khi plugin load
local patch = require("core.patch")
patch.treesitter_ft_to_lang()
patch.treesitter_get_node_text()
patch.fs_rm_empty_dir()

require("plugins")
require("core.colorscheme")
