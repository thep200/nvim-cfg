-- ============================================================
--  plugins/surround.lua
--  Thao tác cặp ký tự bao quanh: ys (thêm), ds (xóa), cs (đổi)
--  Ví dụ: ysiw" bao từ bằng "", cs"' đổi "" thành '', ds( xóa ()
-- ============================================================

return {
    "kylechui/nvim-surround",
    version = "^3.0.0",
    event = "VeryLazy",
    opts = {},
}
