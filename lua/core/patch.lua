-- ============================================================
-- core/patch.lua
-- Gom các patch tương thích Neovim & plugin
-- ============================================================

local M = {}

-- Neovim 0.11: ft_to_lang bị bỏ, redirect sang get_lang
function M.treesitter_ft_to_lang()
    local lang = vim.treesitter.language
    if lang and not lang.ft_to_lang then
        lang.ft_to_lang = lang.get_lang
    end
end

-- Neovim 0.12: get_node_text có thể nhận table thay vì node
function M.treesitter_get_node_text()
    local orig = vim.treesitter.get_node_text
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.treesitter.get_node_text = function(node, source, opts)
        if type(node) == "table" then
            node = node[1]
            if node == nil then return "" end
        end
        return orig(node, source, opts)
    end
end

-- Lualine: tab active hiện relative path, inactive hiện filename
function M.lualine_buffer_name()
    local buffer_class = require("lualine.components.buffers.buffer")
    local orig_name = buffer_class.name

    buffer_class.name = function(self)
        if self.bufnr == vim.api.nvim_get_current_buf() then
            local path = vim.api.nvim_buf_get_name(self.bufnr)
            if path ~= "" then
                return vim.fn.fnamemodify(path, ":~:.")
            end
        end
        return orig_name(self)
    end
end

return M
