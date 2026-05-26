-- ============================================================
--  plugins/autopairs.lua
--  Auto-close brackets / quotes / braces khi gõ ký tự mở.
--
--  Ví dụ:
--    Gõ `(` -> tự thêm `)` và đặt cursor ở giữa: (|)
--    Gõ `"` -> tự thêm `"`: "|"
--    Gõ `{` rồi <Enter> -> tự xuống dòng + indent:
--          {
--            |
--          }
--
--  Tích hợp với nvim-cmp: khi accept item là function -> tự thêm `()`
-- ============================================================

return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",   -- chỉ load khi vào insert -> nhanh startup
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
        local autopairs = require("nvim-autopairs")
        autopairs.setup({
            -- ---- Tự đóng các cặp ----
            check_ts             = true,    -- dùng treesitter để check
                                            -- (vd: không insert ' trong identifier)
            disable_filetype     = { "TelescopePrompt" },

            -- ---- Fast wrap (Alt+e): wrap text đã có trong dấu ----
            -- Vd: cursor ở "hello|" -> Alt+e -> "(hello)"
            fast_wrap = {
                map            = "<M-e>",
                chars          = { "{", "[", "(", '"', "'" },
                pattern        = [=[[%'%"%>%]%)%}%,]]=],
                end_key        = "$",
                keys           = "qwertyuiopzxcvbnmasdfghjkl",
                check_comma    = true,
                highlight      = "Search",
                highlight_grey = "Comment",
            },
        })

        -- ------------------------------------------------------------
        -- Tích hợp với nvim-cmp:
        -- Khi accept item type function/method -> tự thêm "(" sau tên hàm
        -- => không phải gõ "(" thêm sau khi Tab/Enter
        -- ------------------------------------------------------------
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        cmp.event:on(
            "confirm_done",
            cmp_autopairs.on_confirm_done()
        )
    end,
}
