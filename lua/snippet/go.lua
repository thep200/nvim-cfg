-- ============================================================
--  lua/snippet/go.lua
--  Snippet riêng cho Go.
-- ============================================================

local ls = require("luasnip")
local s  = ls.snippet
local t  = ls.text_node
local i  = ls.insert_node
local f  = ls.function_node

return {
    -- meth<Type> + Tab, VD methClient -> func (c *Client) MethodName() (, error) { ... }
    s({ trig = "meth(%a[%w_]*)", regTrig = true, desc = "meth<Type>: Go method" }, {
        f(function(_, snip)
            local typ = snip.captures[1]
            return ("func (%s *%s) "):format(typ:sub(1, 1):lower(), typ)
        end),
        i(1, "MethodName"),
        t("("),
        i(2),
        t(") ("),
        i(3),
        t({ ", error) {", "\t" }),
        i(4),
        t({ "", "}" }),
    }),

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
