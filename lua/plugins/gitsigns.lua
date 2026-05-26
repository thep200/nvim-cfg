-- ============================================================
--  plugins/gitsigns.lua
--  Thay thế: airblade/vim-gitgutter
--
--  Lý do dùng gitsigns.nvim:
--    - Pure Lua, async (gitgutter Vim cũ chạy sync trên file lớn = lag).
--    - Có floating window preview hunk (gitgutter không có).
--    - Set sẵn vim.b.gitsigns_head cho lualine -> không cần fugitive.
--    - Symbol +/~/_ giữ NGUYÊN (ASCII, không cần nerd font).
-- ============================================================

return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },   -- load khi mở file
    config = function()
        require("gitsigns").setup({
            -- ------------------------------------------------------------
            -- Ký hiệu - giữ NGUYÊN từ gitgutter.vim (ASCII, không Nerd Font)
            -- ------------------------------------------------------------
            signs = {
                add          = { text = "+" },
                change       = { text = "~" },
                delete       = { text = "_" },
                topdelete    = { text = "‾" },
                changedelete = { text = "~_" },
                untracked    = { text = "+" },
            },
            -- gitsigns đọc git diff async - hiệu năng rất tốt
            max_file_length = 40000,     -- tương đương g:gitgutter_max_signs = 500
                                          -- (gitsigns đếm theo dòng file, không phải số hunk)

            -- ------------------------------------------------------------
            -- Keymaps (BONUS - gitgutter cũ không có).
            -- Đăng ký ở on_attach để chỉ active trong buffer có git.
            -- ------------------------------------------------------------
            on_attach = function(bufnr)
                local gs   = package.loaded.gitsigns
                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                end

                -- Nhảy giữa các hunk thay đổi
                map("n", "]c", function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() gs.next_hunk() end)
                    return "<Ignore>"
                end, "Next git hunk")

                map("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.prev_hunk() end)
                    return "<Ignore>"
                end, "Prev git hunk")

                -- Preview hunk thay đổi trong floating window
                -- (Tính năng KHÔNG có ở gitgutter Vim cũ)
                map("n", "<leader>hp", gs.preview_hunk,           "Preview hunk")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame current line")
                map("n", "<leader>hr", gs.reset_hunk,             "Reset hunk")
                map("n", "<leader>hs", gs.stage_hunk,             "Stage hunk")
                map("n", "<leader>hu", gs.undo_stage_hunk,        "Undo stage hunk")
            end,
        })
    end,
}
