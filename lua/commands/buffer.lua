-- ============================================================
--  lua/commands/buffer.lua
--  Các command thao tác chung trên buffer (không theo ngôn ngữ).
-- ============================================================

-- Xoá toàn bộ dòng trống (kể cả dòng chỉ chứa whitespace).
-- Mặc định cả file, hỗ trợ range (:'<,'>ClearEmptyLines cho vùng chọn).
-- Xoá vào black-hole register để không ghi đè register đang dùng,
-- giữ nguyên vị trí cửa sổ/con trỏ sau khi xoá.
vim.api.nvim_create_user_command("ClearEmptyLines", function(opts)
    local view = vim.fn.winsaveview()
    vim.cmd(string.format([[silent %d,%dglobal/^\s*$/delete _]], opts.line1, opts.line2))
    vim.fn.winrestview(view)
end, { range = "%", desc = "Clean empty lines" })
