-- ============================================================
--  languages/proto/buf.lua
--  buf_ls (Buf Language Server) — LSP + lint + format cho Protobuf.
--  Diagnostics lấy từ `buf lint`, formatting dùng `buf format`,
--  rule cấu hình qua buf.yaml của từng project.
-- ============================================================

return {
    -- Tên server, dùng cho vim.lsp.config(name, ...)
    name = "buf_ls",

    -- Server cần cài qua mason-lspconfig (ensure_installed)
    mason = { "buf_ls" },

    -- Marker để xác định root của workspace (ưu tiên từ trên xuống)
    root_markers = { "buf.work.yaml", "buf.yaml", "buf.gen.yaml", ".git" },

    -- buf_ls không có settings riêng; lint/breaking rules đọc từ buf.yaml
    settings = {},

    -- Auto-format khi lưu file (BufWritePre) — dùng `buf format` qua LSP
    format_on_save = {
        pattern          = "*.proto",
        organize_imports = false,
    },
}
