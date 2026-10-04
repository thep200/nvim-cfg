-- ============================================================
--  plugins/tabout.lua
--  Nhảy con trỏ ra khỏi cặp ngoặc/quote bằng Tab khi đứng trước
--  ký tự đóng: (|) -> ()|. Không tự map Tab: cmp.lua điều phối
--  chuỗi Copilot -> Cmp -> Snippet -> <Plug>(Tabout).
-- ============================================================

return {
    "abecodes/tabout.nvim",
    event = "InsertEnter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("tabout").setup({
            tabkey           = "",    -- Để trống: không ghi đè map <Tab> của cmp.lua
            backwards_tabkey = "",    -- Tương tự với <S-Tab>
            act_as_tab       = true,  -- Không có gì để nhảy ra -> Tab thụt lề bình thường
            act_as_shift_tab = false,
            default_tab      = "<C-t>",
            default_shift_tab = "<C-d>",
            enable_backwards = true,
            completion       = false, -- Popup completion do cmp.lua xử lý trước rồi
            ignore_beginning = true,  -- Bỏ qua khi con trỏ ở đầu dòng  
            tabouts = {
                { open = "'", close = "'" },
                { open = '"', close = '"' },
                { open = "`", close = "`" },
                { open = "(", close = ")" },
                { open = "[", close = "]" },
                { open = "{", close = "}" },
            },
        })
    end,
}
