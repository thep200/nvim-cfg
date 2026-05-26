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
--    <C-j>      Accept toàn bộ suggestion (giống VSCode)
--    <C-l>      Accept 1 word
--    <C-]>      Bỏ qua suggestion hiện tại
--    <M-]>      Suggestion tiếp theo
--    <M-[>      Suggestion trước đó
-- ============================================================

return {
    "github/copilot.vim",
    event = "InsertEnter",   -- chỉ load khi vào insert mode -> không ảnh hưởng startup
    cmd   = { "Copilot" },
    config = function()
        -- ------------------------------------------------------------
        -- TẮT mapping Tab mặc định của Copilot.
        --
        -- Mặc định Copilot dùng <Tab> để accept suggestion - nhưng <Tab>
        -- đã được nvim-cmp dùng để duyệt completion popup. Để tránh
        -- xung đột:
        --   - Tắt Copilot tab map (g:copilot_no_tab_map = 1)
        --   - Bind <C-j> để accept Copilot (giống VSCode binding)
        -- ------------------------------------------------------------
        vim.g.copilot_no_tab_map = true

        -- Accept toàn bộ suggestion bằng Ctrl+J
        vim.keymap.set("i", "<C-j>", 'copilot#Accept("\\<CR>")', {
            silent  = true,
            expr    = true,           -- expression mapping (Copilot dùng vim function)
            replace_keycodes = false, -- giữ nguyên \<CR> trong expression
            desc    = "Copilot: accept suggestion",
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
            gitcommit    = false,   -- commit message - tự viết thì hơn
            gitrebase    = false,
            ["dap-repl"] = false,
            TelescopePrompt = false,
        }
    end,
}
