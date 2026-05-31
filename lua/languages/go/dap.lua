-- ============================================================
--  languages/go/dap.lua
--  Cấu hình Debug Adapter cho Go (delve qua nvim-dap-go)
-- ============================================================

return {
    -- Filetype để lazy-load nvim-dap
    ft = { "go" },

    -- Plugin phụ thuộc thêm vào nvim-dap
    dependencies = { "leoluz/nvim-dap-go" },

    -- Khởi tạo adapter (được gọi trong config của plugins/dap.lua,
    -- sau khi nvim-dap đã load xong).
    -- Thêm "outputMode": "remote" vào launch.json để forward stdout/stderr về REPL.
    setup = function()
        require("dap-go").setup({
            delve = {
                timeout  = 20,
                detached = true,
            },
        })
    end,

    -- Phím tắt riêng cho Go.
    -- Nhận hàm `k(lhs, rhs, desc)` đã chuẩn hoá từ plugins/dap.lua.
    keys = function(k)
        k("<leader>dt", function() require("dap-go").debug_test() end,      "Debug Nearest Test")
        k("<leader>dT", function() require("dap-go").debug_last_test() end, "Debug Last Test")
    end,
}
