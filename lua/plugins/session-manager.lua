-- ============================================================
--  plugins/auto-session.lua
-- ============================================================
return {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
        suppressed_dirs = { "~/", "~/Downloads", "~/Documents", "/" },
        post_restore_cmds = {
            function()
                vim.schedule(function()
                    pcall(vim.cmd, "Neotree show")
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if vim.api.nvim_buf_is_loaded(buf)
                            and vim.bo[buf].buftype == ""
                            and vim.api.nvim_buf_get_name(buf) ~= ""
                            and vim.bo[buf].filetype == ""
                        then
                            vim.api.nvim_buf_call(buf, function()
                                vim.cmd("filetype detect")
                            end)
                        end
                    end
                end)
            end,
        },
    },
    keys = {
        { "<leader>qs", "<cmd>AutoSession search<CR>",  desc = "Search sessions" },
    },
}
