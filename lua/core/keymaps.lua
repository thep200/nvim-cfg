-- ============================================================
--  core/keymaps.lua
-- ============================================================

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ------------------------------------------------------------
-- Buffer navigation
-- ------------------------------------------------------------

-- Shift+Tab để chuyển buffer tiếp theo
map("n", "<S-Tab>", ":bnext<CR>", opts)

-- ------------------------------------------------------------
-- Tiện ích thêm
-- ------------------------------------------------------------

-- Esc để xoá highlight tìm kiếm sau khi search xong
map("n", "<Esc>", ":nohlsearch<CR>", opts)

-- ------------------------------------------------------------
-- WINDOW SPLIT & NAVIGATION
-- ------------------------------------------------------------

-- 1. Ctrl + Shift + Mũi tên Lên/Xuống để chia màn hình
map("n", "<C-S-Up>",   ":split<CR>", opts)
map("n", "<C-S-Down>", ":split<CR>", opts)
map("n", "<C-S-Left>",  ":vsplit<CR>", opts)
map("n", "<C-S-Right>", ":vsplit<CR>", opts)

-- 2. Shift + Mũi tên Lên/Xuống để di chuyển nhanh giữa các màn hình
map("n", "<S-Up>",   "<C-w>k", opts)
map("n", "<S-Down>", "<C-w>j", opts)
map("n", "<S-Left>",  "<C-w>h", opts)
map("n", "<S-Right>", "<C-w>l", opts)

