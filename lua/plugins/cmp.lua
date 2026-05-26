-- ============================================================
--  plugins/cmp.lua
--  Thay thế: asyncomplete.vim + asyncomplete-lsp.vim
--
--  nvim-cmp = autocomplete engine chuẩn của hệ sinh thái Neovim.
--  Pure Lua, KHÔNG cần Node (như coc.nvim).
--
--  Keymap GIỮ NGUYÊN từ asyncomplete.vim cũ:
--    Tab / S-Tab : duyệt suggestion
--    Enter       : chấp nhận
--    Ctrl-Space  : force refresh
-- ============================================================

return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",      -- chỉ load khi vào insert mode -> startup cực nhanh
    dependencies = {
        -- Sources
        "hrsh7th/cmp-nvim-lsp", -- gợi ý từ LSP (gopls)
        "hrsh7th/cmp-buffer",   -- gợi ý từ buffer hiện tại
        "hrsh7th/cmp-path",     -- gợi ý đường dẫn file

        -- Snippet engine (cmp YÊU CẦU 1 snippet engine - không thể bỏ).
        -- LuaSnip là engine pure Lua nhẹ nhất.
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
    },
    config = function()
        local cmp     = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
            -- ------------------------------------------------------------
            -- Bắt buộc cấu hình snippet expansion (kể cả không xài snippet)
            -- ------------------------------------------------------------
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },

            -- ------------------------------------------------------------
            -- Sources - thứ tự = ưu tiên gợi ý
            -- ------------------------------------------------------------
            sources = cmp.config.sources({
                { name = "nvim_lsp", priority = 1000 },   -- gopls ở đây
                { name = "luasnip",  priority = 750  },
                { name = "buffer",   priority = 500, keyword_length = 3 },
                { name = "path",     priority = 250  },
            }),

            -- ------------------------------------------------------------
            -- Keymaps trong popup - GIỮ NGUYÊN từ asyncomplete.vim cũ
            -- ------------------------------------------------------------
            mapping = cmp.mapping.preset.insert({
                -- Tab: nếu popup mở -> chọn next, nếu trong snippet -> jump,
                -- nếu không -> hành xử Tab bình thường
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                -- S-Tab: ngược lại
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                -- Enter: confirm item ĐANG chọn. Nếu popup đóng -> xuống dòng bình thường
                ["<CR>"] = cmp.mapping(function(fallback)
                    if cmp.visible() and cmp.get_selected_entry() then
                        cmp.confirm({ select = false })
                    else
                        fallback()
                    end
                end),

                -- Ctrl-Space: force refresh popup (giống asyncomplete_force_refresh cũ)
                ["<C-Space>"] = cmp.mapping.complete(),

                -- Ctrl-e: cancel
                ["<C-e>"]     = cmp.mapping.abort(),

                -- Ctrl-d/u: scroll docs
                ["<C-d>"]     = cmp.mapping.scroll_docs(4),
                ["<C-u>"]     = cmp.mapping.scroll_docs(-4),
            }),

            -- ------------------------------------------------------------
            -- Hiển thị popup - cấu hình nhẹ, không icon (theo phong cách
            -- ASCII của bạn)
            -- ------------------------------------------------------------
            formatting = {
                fields = { "abbr", "kind", "menu" },
                format = function(entry, vim_item)
                    -- Hiển thị nguồn gợi ý ở cột menu (LSP/Snippet/Buffer/Path)
                    local menu_map = {
                        nvim_lsp = "[LSP]",
                        luasnip  = "[Snip]",
                        buffer   = "[Buf]",
                        path     = "[Path]",
                    }
                    vim_item.menu = menu_map[entry.source.name] or ""
                    return vim_item
                end,
            },

            window = {
                completion    = cmp.config.window.bordered({ border = "rounded" }),
                documentation = cmp.config.window.bordered({ border = "rounded" }),
            },

            -- ------------------------------------------------------------
            -- Tự bật popup (giống g:asyncomplete_auto_popup = 1)
            -- ------------------------------------------------------------
            completion = {
                autocomplete = { cmp.TriggerEvent.TextChanged },
                keyword_length = 1,                  -- gõ 1 ký tự là gợi ý
                                                     -- (giống g:asyncomplete_min_chars cũ)
            },

            -- Sort theo fuzzy matching (port g:asyncomplete_matchfuzzy)
            sorting = {
                priority_weight = 2,
                comparators = {
                    cmp.config.compare.offset,
                    cmp.config.compare.exact,
                    cmp.config.compare.score,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.locality,
                    cmp.config.compare.kind,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                },
            },
        })
    end,
}
