-- ============================================================
--  core/keymaps.lua
-- ============================================================

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Shift+Tab để chuyển buffer tiếp theo
map("n", "<S-Tab>", ":bnext<CR>", opts)

-- Esc để xoá highlight tìm kiếm sau khi search xong
map("n", "<Esc>", ":nohlsearch<CR>", opts)

-- Ctrl + Shift + h/j/k/l để splitright/splitbelow/vsplit/splitright
map("n", "<C-S-k>",   ":split<CR>", opts)
map("n", "<C-S-j>", ":split<CR>", opts)
map("n", "<C-S-h>",  ":vsplit<CR>", opts)
map("n", "<C-S-l>", ":vsplit<CR>", opts)

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
