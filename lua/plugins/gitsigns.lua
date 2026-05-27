-- ============================================================
--  plugins/gitsigns.lua
-- ============================================================

return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("gitsigns").setup({
            -- ============================================================
            -- 1. Cấu hình giao diện (ASCII tối giản, không cần Nerd Font)
            -- ============================================================
            signs = {
                add          = { text = "+" },
                change       = { text = "~" },
                delete       = { text = "_" },
                topdelete    = { text = "‾" },
                changedelete = { text = "~_" },
                untracked    = { text = "+" },
            },
            max_file_length = 40000,

            -- ============================================================
            -- 2. Hệ thống phím tắt (Chỉ kích hoạt trong file thuộc Git repo)
            -- ============================================================
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                -- Hàm helper bọc keymap cho gọn
                local function map(mode, lhs, rhs, desc, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    opts.silent = true
                    opts.desc = desc
                    vim.keymap.set(mode, lhs, rhs, opts)
                end

                -- ---- ĐIỀU HƯỚNG GIỮA CÁC ĐOẠN CODE THAY ĐỔI (HUNKS) ----
                map("n", "]c", function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() gs.next_hunk() end)
                    return "<Ignore>"
                end, "Next Git Hunk", { expr = true })

                map("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.prev_hunk() end)
                    return "<Ignore>"
                end, "Prev Git Hunk", { expr = true })

                -- ---- THAO TÁC VỚI ĐOẠN CODE NHỎ (HUNK) ----
                map("n", "<leader>hp", gs.preview_hunk,    "Preview Hunk (Xem code cũ/mới)")
                map("n", "<leader>hr", gs.reset_hunk,      "Reset Hunk (Hủy thay đổi đoạn này)")
                map("n", "<leader>hs", gs.stage_hunk,      "Stage Hunk (Đưa đoạn này vào commit)")
                map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")

                -- ---- THAO TÁC VỚI TOÀN BỘ FILE (BUFFER) ----
                map("n", "<leader>gd", gs.diffthis,        "Git Diff (So sánh toàn file)")
                map("n", "<leader>gR", gs.reset_buffer,    "Git Reset (Hủy toàn bộ thay đổi file)")
            end,
        })
    end,
}
