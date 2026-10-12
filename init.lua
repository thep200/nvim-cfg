-- ============================================================
--  Neovim configurations
--  Author: Thep200
-- ============================================================

-- Config chạy thẳng từ thư mục git (nvim -u <repo>/init.lua), không
-- symlink qua ~/.config/nvim. stdpath("config") lúc đó không trỏ về
-- đây, nên mọi chỗ cần đường dẫn config phải dùng vim.g.config_root.
local init_file = debug.getinfo(1, "S").source:sub(2)
vim.g.config_root = vim.fs.dirname(vim.uv.fs_realpath(init_file) or init_file)
vim.opt.rtp:prepend(vim.g.config_root)

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
