-- ============================================================
--  core/keymaps.lua
--  Port từ: keymaps.vim
--
--  CHỈ chứa keymap GLOBAL (không phụ thuộc plugin).
--  Keymap thuộc plugin được khai báo trong file plugin tương ứng
--  để gom theo "domain" - dễ tìm và disable khi gỡ plugin:
--
--    - <C-b>     toggle neo-tree   -> lua/plugins/neo-tree.lua
--    - <C-p>     find files        -> lua/plugins/telescope.lua
--    - <leader>b/f/l search        -> lua/plugins/telescope.lua
--    - gd/gr/K/...  LSP            -> lua/plugins/lsp.lua
--    - <Tab>/<CR>   completion     -> lua/plugins/cmp.lua
-- ============================================================

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ------------------------------------------------------------
-- Buffer navigation
-- ------------------------------------------------------------
-- Shift+Tab để chuyển buffer tiếp theo (giống vim cũ)
map("n", "<S-Tab>", ":bnext<CR>", opts)

-- ------------------------------------------------------------
-- Tiện ích thêm (không có trong vimrc cũ nhưng rất hữu ích)
-- ------------------------------------------------------------
-- Esc để xoá highlight tìm kiếm sau khi search xong
map("n", "<Esc>", ":nohlsearch<CR>", opts)
