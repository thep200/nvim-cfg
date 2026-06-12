-- ============================================================
--  languages/go/dap.lua
-- ============================================================

return {
    ft = { "go" },

    dependencies = { "leoluz/nvim-dap-go" },

    setup = function()
        require("dap-go").setup({
            delve = {
                timeout  = 20,
                detached = true,
            },
        })
    end,

    keys = function(k)
        k("<leader>dt", function() require("dap-go").debug_test() end,      "Debug Nearest Test")
        k("<leader>dT", function() require("dap-go").debug_last_test() end, "Debug Last Test")
    end,
}
