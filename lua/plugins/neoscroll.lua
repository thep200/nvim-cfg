return {
    "karb94/neoscroll.nvim",
    config = function()
        local neoscroll = require('neoscroll')

        neoscroll.setup({
            easing = "quadratic", -- "linear" | "quadratic" | "cubic" | "quartic"

        })

        local function dur(lines)
            return math.min(150, 60 + math.abs(lines) * 2)
        end

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
                    duration    = dur(lines),
                    easing      = "sine",
                })
            end
        end
        vim.keymap.set("n", "j", smooth_jk("j"), { silent = true, desc = "Smooth [count]j" })
        vim.keymap.set("n", "k", smooth_jk("k"), { silent = true, desc = "Smooth [count]k" })

        -- local function smooth_goto(default)
        --     return function()
        --         local count = vim.v.count
        --         local dest
        --         if count > 0 then
        --             dest = count
        --         elseif default == "top" then
        --             dest = 1
        --         else
        --             dest = vim.fn.line("$")
        --         end

        --         local lines = dest - vim.fn.line(".")
        --         if lines == 0 then return end
        --         neoscroll.scroll(lines, {
        --             move_cursor = true,
        --             duration    = dur(lines),
        --             easing      = "quadratic",
        --         })
        --     end
        -- end
        -- vim.keymap.set("n", "gg", smooth_goto("top"),    { silent = true, desc = "Smooth gg / [count]gg" })
        -- vim.keymap.set("n", "G",  smooth_goto("bottom"), { silent = true, desc = "Smooth G / [count]G" })
    end
}
