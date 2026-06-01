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
            -- 2. Inline Blame
            -- ============================================================
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text         = true,
                virt_text_pos     = "eol",
                delay             = 300,
                ignore_whitespace = false,
                italic = true,
            },
            preview_config = {
                border   = "rounded",
                style    = "minimal",
                relative = "cursor",
                row      = 0,
                col      = 1,
            },
            current_line_blame_formatter_nc = '',
            current_line_blame_formatter = " 🐾 #<abbrev_sha> by <author>, <author_time:%R>",

            -- ============================================================
            -- 3. Hệ thống phím tắt (Chỉ kích hoạt trong file thuộc Git repo)
            -- ============================================================
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

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
                    vim.schedule(function() gs.nav_hunk("next") end)
                    return "<Ignore>"
                end, "Next Git Hunk", { expr = true })

                map("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.nav_hunk("prev") end)
                    return "<Ignore>"
                end, "Prev Git Hunk", { expr = true })

                -- ---- THAO TÁC VỚI ĐOẠN CODE NHỎ (HUNK) ----
                -- Trong gitsigns mới: stage_hunk có toggle behavior, thay cho undo_stage_hunk
                map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk (Xem code cũ/mới)")
                map("n", "<leader>hr", gs.reset_hunk,   "Reset Hunk (Hủy thay đổi đoạn này)")
                map("n", "<leader>hs", gs.stage_hunk,   "Stage / Unstage Hunk (toggle)")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line (popup chi tiết)")
                map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle Inline Blame (git hint)")

                -- ---- THAO TÁC VỚI TOÀN BỘ FILE (BUFFER) ----
                map("n", "<leader>gd", gs.diffthis,     "Git Diff (So sánh toàn file)")
                map("n", "<leader>gR", gs.reset_buffer, "Git Reset (Hủy toàn bộ thay đổi file)")
            end,
        })

        -- ============================================================
        -- 4. Inline blame custom
        -- ============================================================
        local function set_blame_italic()
            vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", {
                fg     = "#525252",
                italic = true,
            })
        end

        set_blame_italic()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group    = vim.api.nvim_create_augroup("GitSignsBlameItalic", { clear = true }),
            callback = set_blame_italic,
        })
    end,
}
