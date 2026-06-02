return {
    "karb94/neoscroll.nvim",
    config = function()
        local neoscroll = require('neoscroll')

        neoscroll.setup({
            easing = "quadratic", -- "linear" | "quadratic" | "cubic" | "quartic"
        })

        -- ========================================================
        -- Smooth [count]j / [count]k  (vd: 100j, 30k)
        --   - Có count  -> cuộn mượt theo số dòng đó
        --   - Không count-> j/k bình thường, tức thì (đọc code từng dòng)
        -- ========================================================
        local function smooth_jk(dir) -- dir = "j" hoặc "k"
            return function()
                local count = vim.v.count
                if count == 0 then
                    vim.cmd("normal! " .. dir)
                    return
                end

                local lines = (dir == "j") and count or -count
                neoscroll.scroll(lines, {
                    move_cursor = true,
                    duration = math.min(150, 60 + math.abs(lines) * 2),
                    easing = "sine",
                })
            end
        end

        vim.keymap.set("n", "j", smooth_jk("j"), { silent = true, desc = "Smooth [count]j" })
        vim.keymap.set("n", "k", smooth_jk("k"), { silent = true, desc = "Smooth [count]k" })
    end
}
