return {
    'MagicDuck/grug-far.nvim',
    config = function()
        require('grug-far').setup({})
    end,
    keys = {
        { "<leader>rp", "<cmd>GrugFar<CR>", desc = "Search and Replace on Project" },
    }
}
