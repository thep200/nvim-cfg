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

-- gopls package-rename gửi LSP DeleteFile cho folder cũ (đã rỗng) nhưng không
-- kèm options.recursive; vim.fs.rm khi đó error "is a directory" và làm
-- apply_workspace_edit dừng giữa chừng. Thử rmdir folder rỗng trước khi
-- rơi về hành vi gốc.
function M.fs_rm_empty_dir()
    local orig = vim.fs.rm
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.fs.rm = function(path, opts)
        opts = opts or {}
        local stat = vim.uv.fs_stat(path)
        if stat and stat.type == "directory" and not opts.recursive and not opts.force then
            if vim.uv.fs_rmdir(path) then return end
        end
        return orig(path, opts)
    end
end

return M
