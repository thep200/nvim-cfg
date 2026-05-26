-- ============================================================
--  plugins/copilot.lua
--  GitHub Copilot - AI code suggestions inline
--
--  ⚠️ LƯU Ý: copilot.vim YÊU CẦU Node.js (>= 18) để chạy agent.
--  Đây là exception duy nhất trong stack "no Node" của bạn vì
--  Copilot không có lựa chọn pure Lua thay thế.
--
--  Lần đầu sử dụng:
--    1. Chạy `:Copilot setup` -> mở browser để xác thực GitHub.
--    2. Sau khi xong, Copilot sẽ tự gợi ý code dạng "ghost text"
--       (chữ xám mờ) khi đang gõ.
--
--  Phím tắt:
--    <Tab>      Accept Copilot suggestion (PRIORITY - định nghĩa ở cmp.lua)
--    <C-j>      Accept Copilot suggestion (backup - không qua cmp)
--    <C-l>      Accept 1 word
--    <M-]>      Suggestion tiếp theo
--    <M-[>      Suggestion trước đó
--    <C-]>      Bỏ qua suggestion hiện tại
-- ============================================================

return {
    "github/copilot.vim",
    event = "InsertEnter",   -- chỉ load khi vào insert mode -> không ảnh hưởng startup
    cmd   = { "Copilot" },
    config = function()
        -- ------------------------------------------------------------
        -- TẮT mapping Tab mặc định của Copilot.
        --
        -- Copilot mặc định bind <Tab> ngay từ filetype VimL plugin -> nuốt
        -- mapping <Tab> ta định nghĩa ở cmp. Phải tắt bằng cờ này TRƯỚC khi
        -- copilot.vim load:
        --   g:copilot_no_tab_map = true
        -- Logic <Tab> để accept Copilot được xử lý ở plugins/cmp.lua
        -- (priority: Copilot > cmp navigation > snippet > fallback).
        -- ------------------------------------------------------------
        vim.g.copilot_no_tab_map = true

        -- Backup mapping: Ctrl+J accept Copilot (không qua cmp - chạy
        -- thẳng bằng expression mapping của copilot.vim). Hữu ích khi
        -- cmp bị tắt hoặc không load.
        vim.keymap.set("i", "<C-j>", 'copilot#Accept("\\<CR>")', {
            silent  = true,
            expr    = true,           -- expression mapping (Copilot dùng vim function)
            replace_keycodes = false, -- giữ nguyên \<CR> trong expression
            desc    = "Copilot: accept suggestion (backup)",
        })

        -- Accept 1 word (cho phép review từng phần suggestion)
        vim.keymap.set("i", "<C-l>", "<Plug>(copilot-accept-word)", {
            silent = true,
            desc   = "Copilot: accept next word",
        })

        -- ------------------------------------------------------------
        -- Tắt Copilot cho 1 số filetype không cần (privacy / không hữu ích)
        -- ------------------------------------------------------------
        vim.g.copilot_filetypes = {
            ["*"]        = true,    -- mặc định bật cho mọi filetype
            gitcommit    = true,   -- commit message - tự viết thì hơn
        }
    end,
}
