-- ============================================================
--  core/keymaps.lua
-- ============================================================

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Esc để xoá highlight tìm kiếm sau khi search xong
map("n", "<Esc>", ":nohlsearch<CR>", opts)

-- ============================================================
-- Cuộn trang và tự động giữ con trỏ ở giữa màn hình
-- ============================================================
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Split window management
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width" })

-- Chế độ Normal ("n"): Đè Ctrl + h/j/k/l để nhảy nhanh giữa các màn hình
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Delete into void
-- <leader>dd to delete a line without copying it to the clipboard
map("n", "<leader>d", '"_d', { desc = "Delete without copying" })
map("v", "<leader>d", '"_d', { desc = "Delete without copying" })
map("n", "x", '"_x', { desc = "Delete char without copying" })

-- Quick quit
map("n", "<leader>qq", "<cmd>wqa<CR>", { desc = "Save all and quit" })
map("n", "<leader>qQ", "<cmd>qa!<CR>", { desc = "Quit without saving" })

--- Remove default keymaps
pcall(vim.keymap.del, "n", "grr") -- Xóa List References mặc định
pcall(vim.keymap.del, "n", "gri") -- Xóa Implementation mặc định
pcall(vim.keymap.del, "n", "grn") -- Xóa Rename mặc định
pcall(vim.keymap.del, "n", "gra") -- Xóa luôn Code Action mặc định (cho sạch tiền tố)
pcall(vim.keymap.del, "n", "grt") -- Xóa Type Definition mặc định (nếu có)
pcall(vim.keymap.del, "n", "grx") -- Run Codelens actions

-- ============================================================
-- Copy Diagnostic Message tại dòng hiện tại
-- ============================================================
map('n', '<leader>cd', function()
    local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diagnostics = vim.diagnostic.get(0, { lnum = current_line })
    if #diagnostics == 0 then return end
    local message = diagnostics[1].message
    vim.fn.setreg('+', message)
    vim.notify("Diagnostics copied: " .. message, vim.log.levels.INFO)
end, { desc = "Copy Diagnostic message" })
