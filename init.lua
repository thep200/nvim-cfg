-- ============================================================
--  Neovim configuration - Entry point
--  Author: Thep200
--
--  Thứ tự load:
--    1. options    - Set các option cơ bản (BẮT BUỘC load TRƯỚC plugins
--                    vì 1 số plugin đọc options khi setup)
--    2. keymaps    - Phím tắt global (không phụ thuộc plugin)
--    3. autocmds   - Auto-save / auto-reload
--    4. plugins    - lazy.nvim sẽ bootstrap & load toàn bộ plugin
--    5. colorscheme- Load CUỐI vì cần override highlight của các plugin
--                    (vd: NeoTreeXxx, GitSignsXxx chỉ tồn tại sau khi
--                     plugin được setup xong)
-- ============================================================

require("core.options")
require("core.keymaps")
require("core.autocmds")
-- ft_to_lang bị xóa trong Neovim 0.10+, telescope vẫn gọi nó -> shim
if vim.treesitter.language and not vim.treesitter.language.ft_to_lang then
    vim.treesitter.language.ft_to_lang = vim.treesitter.language.get_lang
        or function() return nil end
end

require("plugins")           -- lazy.nvim bootstrap + load plugin specs
require("core.colorscheme")  -- LOAD CUỐI để override highlight plugin
