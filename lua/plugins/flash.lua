-- ============================================================
--  plugins/flash.lua
-- ============================================================

return {
    "folke/flash.nvim",
    event = "VeryLazy",

    opts = {
        label = {
            uppercase = false,
        },

        modes = {
            -- `/`, `?`
            search = {
                enabled = true,
                highlight = {
                    backdrop = false,
                },
            },

            char = {
                enabled     = false,
                jump_labels = false,
                multi_line  = false,
            },
        },

        prompt = {
            enabled = false,
            prefix = { { "⚡", "FlashPromptIcon" } },
        },
    },

    -- ------------------------------------------------------------
    -- KEYMAPS
    -- ------------------------------------------------------------
    keys = {
        -- Jump kèm hiệu ứng (lua/animation/): sóng tím lan trong lúc chọn
        -- label, bump tại điểm đi (nhanh) và điểm đáp (chậm hơn chút)
        {
            "s",
            mode = { "n", "x", "o" },
            function()
                local anim = require("animation.bump")
                -- Tạm tắt hiệu ứng sóng (animation/wave.lua); mở lại thì bỏ
                -- comment các dòng wave bên dưới
                -- local wave = require("animation.wave")
                -- wave.start() -- sóng phát liên tục trong lúc flash chờ chọn điểm
                require("flash").jump({
                    action = function(match, state)
                        -- wave.stop() -- chọn xong là sóng kết thúc ngay
                        local from = vim.api.nvim_win_get_cursor(0)
                        -- Điểm xuất phát: vòng co vào tâm (đảo ngược điểm đến)
                        anim.bump(vim.api.nvim_get_current_buf(), from[1], from[2],
                            { interval = 15, reverse = true })
                        require("flash.jump").jump(match, state) -- hành vi nhảy mặc định
                        vim.defer_fn(function()
                            -- Đọc vị trí con trỏ TẠI THỜI ĐIỂM vẽ: toạ độ chụp
                            -- sớm sẽ lệch nếu operator (d/c + s) xoá text hoặc
                            -- format async sửa buffer trong lúc chờ
                            local cur = vim.api.nvim_win_get_cursor(0)
                            anim.bump(vim.api.nvim_get_current_buf(), cur[1], cur[2], { interval = 25 })
                        end, 30) -- bump đáp trễ chút cho cảm giác bật -> tiếp đất
                    end,
                })
                -- wave.stop() -- flash chạy đồng bộ: tới đây = nhảy xong hoặc Esc huỷ
            end,
            desc = "Flash jump",
        },
        { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash treesitter select" },
        { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Flash remote" },
        { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Flash treesitter search" },
        { "<C-s>", mode = "c",               function() require("flash").toggle() end,            desc = "Toggle Flash search" },
    },
}
