-- ============================================================
-- plugins/copilot.lua
-- ============================================================

return {
    "github/copilot.vim",
    event = "InsertEnter",
    cmd   = "Copilot",
    config = function()
        -- Tắt phím Tab mặc định của Copilot để nhường quyền cho nvim-cmp
        vim.g.copilot_no_tab_map = true

        -- Lưu ý: Phím <Tab> chính đã được cấu hình trong plugins/cmp.lua
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

        vim.g.copilot_filetypes = {
            ["*"]           = true,   -- Mặc định bật cho mọi file
            gitcommit       = false,  -- Tắt khi viết git commit
            TelescopePrompt = false,
        }
    end,
}
