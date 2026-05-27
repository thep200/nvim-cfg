-- ============================================================
--  plugins/which-key.lua
--  Popup cheatsheet hiển thị các phím tắt còn lại khi user nhấn 1 prefix.
--
--  Vd: nhấn `<leader>` -> popup hiện ngay các phím tắt bắt đầu bằng leader:
--    <leader>f -> Grep project
--    <leader>b -> List buffers
--    <leader>ca -> Code action
--    ...
--
--  Vô cùng hữu ích khi đang học config mới hoặc lâu không dùng. Plugin
--  tự đọc các keymap đã register (qua vim.keymap.set với desc) - không
--  cần khai báo thủ công.
-- ============================================================

return {
    "folke/which-key.nvim",
    event = "VeryLazy",      -- load sau khi UI vẽ xong
    opts = {
        -- ---- Thời gian chờ trước khi popup hiện (ms) ----
        -- Mặc định 1000ms hơi lâu - 400ms vừa đủ nhanh mà không gây ức chế
        delay = function(ctx)
            return ctx.plugin and 0 or 400
        end,

        -- ---- Hiển thị ----
        preset = "modern",   -- "classic" | "modern" | "helix"
                             -- "modern" có border rounded, layout đẹp nhất

        win = {
            border = "rounded",
            padding = { 1, 2 },
        },

        -- ---- Icons OFF ----
        -- (không phụ thuộc Nerd Font cho which-key)
        icons = {
            mappings  = false,   -- không show icon trước description
            breadcrumb = " > ",  -- ASCII separator giữa các prefix
            separator = " -> ",  -- ASCII separator giữa key & desc
            group     = "+",     -- prefix cho group (vd: +file, +git)
        },

        -- ---- Spec: định nghĩa group names cho các prefix ----
        spec = {
            { "<leader>f", group = "Find / Telescope" },
            { "<leader>h", group = "Git Hunks (gitsigns)" },
            { "<leader>c", group = "Code (LSP)" },
            { "<leader>r", group = "Rename / Refactor" },
            { "<leader>g", group = "Git" },
            { "<leader>d", group = "Debug (DAP)" },
            { "[",         group = "Prev ..." },
            { "]",         group = "Next ..." },
            { "g",         group = "Goto ..." },
        },
    },
    keys = {
        -- Nhấn <leader>? để xem TẤT CẢ keymaps đã register
        {
            "<leader>?",
            function() require("which-key").show({ global = false }) end,
            desc = "Buffer Keymaps (which-key)",
        },
    },
}
