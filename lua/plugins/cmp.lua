-- ============================================================
-- plugins/cmp.lua
-- Cấu hình Autocomplete Engine (nvim-cmp)
-- Tích hợp: LSP, Snippets, Buffer, Path & GitHub Copilot
-- ============================================================

return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "zbirenbaum/copilot.lua",    -- load Copilot trước khi cmp check ghost text
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
    },
    config = function()
        local cmp     = require("cmp")
        local luasnip = require("luasnip")
        local copilot = require("copilot.suggestion")
        local kind_icons = require("core.material").icons.kind

        -- Copilot có đang hiển thị ghost text không
        local function has_copilot_suggestion()
            local ok, visible = pcall(copilot.is_visible)
            return ok and visible
        end

        cmp.setup({
            -- ============================================================
            -- 1. Snippet Engine (Bắt buộc phải có để mở rộng code)
            -- ============================================================
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },

            -- ============================================================
            -- 2. Nguồn dữ liệu Autocomplete (Xếp hạng theo độ ưu tiên)
            -- ============================================================
            sources = cmp.config.sources({
                { name = "nvim_lsp", priority = 1000 },
                { name = "luasnip",  priority = 750  },
                { name = "buffer",   priority = 500, keyword_length = 3 },
                { name = "path",     priority = 250  },
            }),

            -- ============================================================
            -- 3. Cấu hình giao diện Popup (Giữ phong cách tối giản)
            -- ============================================================
            -- formatting = {
            --     -- Thu tu cot: ICON (kind) -> TEN (abbr) -> NGUON (menu)
            --     fields = { "abbr", "kind", },
            --     -- fields = { "kind", "abbr", "menu" },
            --     format = function(entry, vim_item)
            --         -- Chi hien icon o cot kind, dung truoc ten item
            --         vim_item.kind = kind_icons[vim_item.kind] or ""

            --         local menu_map = {
            --             nvim_lsp = "[LSP]",
            --             luasnip  = "[Snip]",
            --             buffer   = "[Buf]",
            --             path     = "[Path]",
            --         }
            --         vim_item.menu = menu_map[entry.source.name] or ""
            --         return vim_item
            --     end,
            -- },
            formatting = {
                -- Thu tu cot: TEN (abbr) -> ICON + TEN KIND (kind) -> NGUON (menu)
                fields = { "abbr", "kind" },
                -- fields = { "abbr", "kind", "menu" },
                format = function(entry, vim_item)
                    -- Cot kind = icon + ten kind, vd: " Function", " Method"
                    local icon = kind_icons[vim_item.kind] or ""
                    vim_item.kind = string.format("%s %s", icon, vim_item.kind)

                    -- local menu_map = {
                    --     nvim_lsp = "[LSP]",
                    --     luasnip  = "[Snip]",
                    --     buffer   = "[Buf]",
                    --     path     = "[Path]",
                    -- }
                    -- vim_item.menu = menu_map[entry.source.name] or ""
                    return vim_item
                end,
            },

            window = {
                completion    = cmp.config.window.bordered({ border = "rounded" }),
                documentation = cmp.config.window.bordered({ border = "rounded" }),
            },

            -- ============================================================
            -- 4. Điều kiện kích hoạt & Thuật toán sắp xếp (Fuzzy Matching)
            -- ============================================================
            completion = {
                autocomplete   = { cmp.TriggerEvent.TextChanged },
                keyword_length = 1,
            },
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

            -- ============================================================
            -- 5. Cấu hình Phím tắt (Bao gồm logic ưu tiên cho Copilot)
            -- ============================================================
            mapping = cmp.mapping.preset.insert({
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"]     = cmp.mapping.abort(),
                ["<C-d>"]     = cmp.mapping.scroll_docs(4),
                ["<C-u>"]     = cmp.mapping.scroll_docs(-4),

                -- Enter: chỉ xác nhận khi đang chọn 1 item
                ["<CR>"] = cmp.mapping(function(fallback)
                    if cmp.visible() and cmp.get_selected_entry() then
                        cmp.confirm({ select = false })
                    else
                        fallback()
                    end
                end),

                -- Tab: Copilot -> Cmp -> Snippet -> Tab thường
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if has_copilot_suggestion() then
                        copilot.accept()
                    elseif cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                -- Shift+Tab: Cmp & Snippet
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
        })
    end,
}
