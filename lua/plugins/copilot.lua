-- ============================================================
-- plugins/copilot.lua
-- Cấu hình GitHub Copilot (Gợi ý code AI bằng Ghost Text)
-- Yêu cầu hệ thống: Cần cài đặt Node.js (>= 18)
-- ============================================================

return {
    "github/copilot.vim",
    event = "InsertEnter",
    cmd   = "Copilot",
    config = function()
        -- ============================================================
        -- 1. Xử lý xung đột phím tắt
        -- Tắt phím Tab mặc định của Copilot để nhường quyền cho nvim-cmp
        -- ============================================================
        vim.g.copilot_no_tab_map = true

        -- ============================================================
        -- 2. Phím tắt điều khiển (Insert Mode)
        -- Lưu ý: Phím <Tab> chính đã được cấu hình trong plugins/cmp.lua
        -- ============================================================
        local map = vim.keymap.set

        -- Phím backup để nhận code (Dùng khi nvim-cmp bị lỗi hoặc tắt)
        map("i", "<C-j>", 'copilot#Accept("\\<CR>")', {
            silent           = true,
            expr             = true,
            replace_keycodes = false,
            desc             = "Copilot: Accept Suggestion (Backup)",
        })

        -- Nhận từng từ một (Giúp kiểm soát code AI sinh ra tốt hơn)
        map("i", "<C-l>", "<Plug>(copilot-accept-word)", {
            silent = true,
            desc   = "Copilot: Accept Next Word"
        })

        -- ============================================================
        -- 3. Quản lý Filetype (Bật/Tắt theo loại file)
        -- ============================================================
        vim.g.copilot_filetypes = {
            ["*"]           = true,  -- Mặc định bật cho mọi file
            gitcommit       = true,  -- Tắt khi viết git commit
            TelescopePrompt = false,
        }
    end,
}
