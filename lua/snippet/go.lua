-- ============================================================
--  lua/snippet/go.lua
--  Snippet riêng cho Go.
-- ============================================================

local ls = require("luasnip")
local s  = ls.snippet
local t  = ls.text_node
local i  = ls.insert_node

return {
    -- if err != nil { ... } với con trỏ đặt giữa block
    s({ trig = "errl", desc = "if err != nil block" }, {
        t({ "if err != nil {", "\t" }),
        i(1),
        t({ "", "}" }),
    }),

    -- func TestXxx(t *testing.T) { ... }, nhập tên trước rồi Tab vào body
    s({ trig = "testf", desc = "Go test function" }, {
        t("func Test"),
        i(1, "Name"),
        t({ "(t *testing.T) {", "\t" }),
        i(2),
        t({ "", "}" }),
    }),
}
