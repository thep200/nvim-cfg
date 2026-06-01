-- ============================================================
--  core/keymaps.lua
-- ============================================================

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Shift+Tab để chuyển buffer tiếp theo
map("n", "<S-Tab>", ":bnext<CR>", opts)

-- Esc để xoá highlight tìm kiếm sau khi search xong
map("n", "<Esc>", ":nohlsearch<CR>", opts)

-- Recent projects
map("n", "<leader>fp", function() require("core.projects").open() end, { noremap = true, silent = true, desc = "Find recent projects" })

-- Ctrl + Shift + Mũi tên Lên/Xuống để chia màn hình
map("n", "<C-S-Up>",   ":split<CR>", opts)
map("n", "<C-S-Down>", ":split<CR>", opts)
map("n", "<C-S-Left>",  ":vsplit<CR>", opts)
map("n", "<C-S-Right>", ":vsplit<CR>", opts)

-- Shift + Mũi tên Lên/Xuống để di chuyển nhanh giữa các màn hình
map("n", "<S-Up>",   "<C-w>k", opts)
map("n", "<S-Down>", "<C-w>j", opts)
map("n", "<S-Left>",  "<C-w>h", opts)
map("n", "<S-Right>", "<C-w>l", opts)


-- ============================================================
-- Copy Diagnostic Message tại dòng hiện tại
-- ============================================================
vim.keymap.set('n', '<leader>cd', function()
    -- Lấy vị trí dòng hiện tại của con trỏ (API của Neovim đếm từ 0)
    local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1

    -- Lấy danh sách các diagnostics ở dòng đó
    local diagnostics = vim.diagnostic.get(0, { lnum = current_line })

    -- Kiểm tra xem có lỗi/cảnh báo nào không
    if #diagnostics == 0 then
        return
    end

    -- Lấy nội dung thông báo của lỗi đầu tiên tìm thấy
    local message = diagnostics[1].message

    -- Lưu vào clipboard hệ thống (register '+')
    vim.fn.setreg('+', message)

    -- Hiển thị thông báo xác nhận góc màn hình
    vim.notify("Copied " .. message, vim.log.levels.INFO)

end, { desc = "Copy Diagnostic message" })
