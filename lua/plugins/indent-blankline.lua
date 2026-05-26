-- ============================================================
--  plugins/indent-blankline.lua
--  Hiển thị các dòng dọc mờ ở mỗi indent level - dễ nhìn nested code.
--
--  Ví dụ trên Go:
--      func main() {
--      │   for i := 0; i < 10; i++ {
--      │   │   if i % 2 == 0 {
--      │   │   │   fmt.Println(i)
--      │   │   }
--      │   }
--      }
--  Các "│" mờ là indent-blankline.
-- ============================================================

return {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",                                -- name của Lua module
    event = { "BufReadPost", "BufNewFile" },      -- lazy-load khi mở file
    opts = {
        indent = {
            char = "│",                           -- ASCII-compatible Unicode box-drawing
                                                  -- (không cần Nerd Font)
            tab_char = "│",
        },
        scope = {
            enabled = true,                       -- highlight scope hiện tại
            show_start = false,                   -- không show "scope start" indicator
            show_end   = false,
            -- Scope dùng treesitter để xác định block code chứa cursor
            -- Cần nvim-treesitter (đã có trong stack)
        },
        exclude = {
            filetypes = {
                "help", "alpha", "dashboard", "neo-tree", "Trouble",
                "lazy", "mason", "notify", "toggleterm", "lazyterm",
            },
        },
    },
    config = function(_, opts)
        -- ------------------------------------------------------------
        -- Custom màu cho indent line - đồng bộ theme zed_github_dark
        -- ------------------------------------------------------------
        local hi  = vim.api.nvim_set_hl
        hi(0, "IblIndent", { fg = "#30363d" })   -- xám đậm cho line mờ
        hi(0, "IblScope",  { fg = "#9198a1" })   -- xám sáng cho scope active

        require("ibl").setup(opts)
    end,
}
